extends CanvasLayer
class_name GameOverDialog

@export var anim_player : AnimationPlayer
@export var particles : CPUParticles2D

@export var button_back : TextureButton
@export var button_restart : TextureButton
@export var button_undo : TextureButton
@export var button_next : TextureButton

@export var audio_player : AudioStreamPlayer
@export var audio_player_2 : AudioStreamPlayer

@export var label : Label
@export var emoji : TextureRect

@export var allow_undo := false

func _ready() -> void:
	button_back.pressed.connect(_on_button_back_pressed)
	button_restart.pressed.connect(_on_button_restart_pressed)
	button_undo.pressed.connect(_on_button_undo_pressed)
	button_next.pressed.connect(_on_button_next_pressed)
	
	button_undo.set_visible(allow_undo)
	
	particles.emitting = false
	anim_player.stop()
	hide()
	
	label.add_theme_font_override("font", PuzzleFramework.font_heading)
	
	PuzzleFramework.puzzle_done.connect(activate)
	PuzzleFramework.puzzle_reopened.connect(deactivate)

func activate(player_won := false) -> void:
	show()
	label.set_text("You Won!" if player_won else "Oh no ...")
	emoji.texture = load("res://puzzle-framework/ui/emojis/large/game-over-good.png" if player_won else "res://puzzle-framework/ui/emojis/large/game-over-bad.png")
	
	anim_player.speed_scale = 1.0
	
	anim_player.play("reveal")
	
	if player_won: particles.emitting = true
	
	# thickening the effect with two separate audio files just gives a much better feeling reward
	audio_player.stream = load("res://puzzle-framework/game/sfx/game_win.ogg") if player_won else load("res://puzzle-framework/game/sfx/game_loss.ogg")
	audio_player_2.stream = load("res://puzzle-framework/game/sfx/game_win_2.ogg") if player_won else load("res://puzzle-framework/game/sfx/game_loss_2.ogg")
	
	audio_player.play()
	audio_player_2.play()

func deactivate() -> void:
	anim_player.speed_scale = randf_range(2.5, 3.5)
	anim_player.play_backwards("reveal")
	await anim_player.animation_finished
	hide()

func is_busy() -> bool:
	return anim_player.is_playing()

func _on_button_back_pressed() -> void:
	if is_busy(): return
	PuzzleFramework.go_back_to_menu()

func _on_button_restart_pressed() -> void:
	if is_busy(): return
	PuzzleFramework.reload_current_puzzle()

func _on_button_next_pressed() -> void:
	if is_busy(): return
	PuzzleFramework.load_new_puzzle()

func _on_button_undo_pressed() -> void:
	if is_busy(): return
	PuzzleFramework.reopen_puzzle()
