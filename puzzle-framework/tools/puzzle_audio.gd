extends Node
class_name PuzzleAudio

var bg_audio : AudioStreamPlayer
var button_audio : AudioStreamPlayer
var state_audio : AudioStreamPlayer
var undo_audio : AudioStreamPlayer
var audio_bus_names : Array[String] = ["Game", "Background", "UI"]

static func play_audio_nice(ap:Node) -> void:
	if ap.bus == "Master": ap.bus = "Game"
	apply_pitch_shift(ap)
	ap.play()

static func apply_pitch_shift(ap:Node) -> void:
	var base := 1.05946309436
	var rand_num := randi_range(-2, 2)
	ap.pitch_scale = pow(base, rand_num)

# Done in enter_tree to ensure it grabs all buttons added later
func _enter_tree() -> void:
	get_tree().node_added.connect(_on_node_added)

func _ready() -> void:
	create_audio_busses()
	create_audio_players()

func create_audio_busses() -> void:
	for bus_name in audio_bus_names:
		AudioServer.add_bus()
		var new_bus_index := AudioServer.get_bus_count() - 1
		AudioServer.set_bus_name(new_bus_index, bus_name)

func create_audio_players() -> void:
	button_audio = AudioStreamPlayer.new()
	add_child(button_audio)
	button_audio.bus = "UI"
	button_audio.stream = preload("res://puzzle-framework/ui/ui_button_press.ogg")
	button_audio.volume_db = -9
	
	state_audio = AudioStreamPlayer.new()
	add_child(state_audio)
	state_audio.bus = "Game"
	state_audio.stream = preload("res://puzzle-framework/game/sfx/game_new.ogg")
	state_audio.volume_db = -6
	
	undo_audio = AudioStreamPlayer.new()
	add_child(undo_audio)
	undo_audio.bus = "UI"
	undo_audio.stream = preload("res://puzzle-framework/ui/ui_undo.ogg")

func _on_node_added(node):
	if (node is Button) or (node is TextureButton):
		node.pressed.connect(play_ui_button_sound)
		node.mouse_entered.connect(play_ui_button_sound)
		
func play_ui_button_sound():
	play_audio_nice(button_audio)

func load_background_music(bg_music:Array[AudioStream]) -> void:
	bg_audio = AudioStreamPlayer.new()
	bg_audio.bus = "Background"
	add_child(bg_audio)
	
	var randomizer := AudioStreamRandomizer.new()
	randomizer.playback_mode = AudioStreamRandomizer.PLAYBACK_RANDOM_NO_REPEATS
	for song in bg_music:
		randomizer.add_stream(-1, song)
	bg_audio.stream = randomizer
	bg_audio.play()
