extends CanvasLayer
class_name GameOverDialog

@export var anim_player : AnimationPlayer
@export var particles : CPUParticles2D

@export var button_back : TextureButton
@export var button_restart : TextureButton
@export var button_next : TextureButton

@export var audio_player : AudioStreamPlayer
@export var audio_player_2 : AudioStreamPlayer

@export var label : Label
@export var emoji : TextureRect

func _ready() -> void:
	button_back.pressed.connect(_on_button_back_pressed)
	button_restart.pressed.connect(_on_button_restart_pressed)
	button_next.pressed.connect(_on_button_next_pressed)
	
	particles.emitting = false
	anim_player.stop()
	hide()
	
	label.add_theme_font_override("font", PuzzleFramework.font_heading)
	
	PuzzleFramework.puzzle_done.connect(activate)

func activate(player_won := false) -> void:
	show()
	label.set_text("You Won!" if player_won else "Oh no ...")
	emoji.texture = load("res://puzzle-framework/ui/emojis/large/game-over-good.png" if player_won else "res://puzzle-framework/ui/emojis/large/game-over-bad.png")
	anim_player.play("reveal")
	if player_won: particles.emitting = true
	
	# thickening the effect with two separate audio files just gives a much better feeling reward
	audio_player.stream = load("res://puzzle-framework/game/sfx/game_win.ogg") if player_won else load("res://puzzle-framework/game/sfx/game_loss.ogg")
	audio_player_2.stream = load("res://puzzle-framework/game/sfx/game_win_2.ogg") if player_won else load("res://puzzle-framework/game/sfx/game_loss_2.ogg")
	
	audio_player.play()
	audio_player_2.play()

func _on_button_back_pressed() -> void:
	PuzzleFramework.go_back_to_menu()

func _on_button_restart_pressed() -> void:
	PuzzleFramework.reload_current_puzzle()

func _on_button_next_pressed() -> void:
	PuzzleFramework.load_new_puzzle()
