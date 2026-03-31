extends CanvasLayer
class_name PuzzleGameMenu

@export var container : MarginContainer
@export var label_seed : Label

@export var button_back : TextureButton
@export var button_restart : TextureButton
@export var button_undo : TextureButton
@export var button_hint : TextureButton
@export var button_next : TextureButton

@export var label_feedback : Label

@export var allow_back := true
@export var allow_restart := true
@export var allow_undo := false
@export var allow_hint := false
@export var allow_next := true

@export var size := 96.0
@export var label_seed_color := Color.WHITE

func _ready() -> void:
	button_back.pressed.connect(_on_button_back_pressed)
	button_restart.pressed.connect(_on_button_restart_pressed)
	button_undo.pressed.connect(_on_button_undo_pressed)
	button_hint.pressed.connect(_on_button_hint_pressed)
	button_next.pressed.connect(_on_button_next_pressed)
	
	if not allow_back: button_back.hide()
	if not allow_undo: button_undo.hide()
	if not allow_next: button_next.hide()
	if not allow_hint: button_hint.hide()
	if not allow_restart: button_restart.hide()
	
	container.custom_minimum_size.y = size
	
	label_seed.add_theme_color_override("font_color", label_seed_color)
	label_seed.add_theme_font_override("font", PuzzleFramework.font_heading)
	label_feedback.add_theme_font_override("font", PuzzleFramework.font_heading)
	
	set_feedback(PuzzleSettings.get_difficulty().feedback)
	set_label_text("Difficulty: " + PuzzleSettings.get_difficulty_string() + " | Seed: " + str(PuzzleFramework.puzzle_seed))

	PuzzleFramework.puzzle_done.connect(_on_puzzle_done)

func set_label_text(txt:String) -> void:
	label_seed.set_text(txt)

func _on_button_back_pressed() -> void:
	PuzzleFramework.go_back_to_menu()

func _on_button_restart_pressed() -> void:
	PuzzleFramework.reload_current_puzzle()

func _on_button_undo_pressed() -> void:
	if (not PuzzleFramework.commands) or (not allow_undo): return
	PuzzleFramework.commands.undo_last_turn()

func _on_button_hint_pressed() -> void:
	if (not PuzzleFramework.commands) or (not allow_hint): return
	PuzzleFramework.commands.give_next_hint()

func _on_button_next_pressed() -> void:
	PuzzleFramework.load_new_puzzle()

func _on_puzzle_done(_player_won:bool) -> void:
	queue_free()

func set_feedback(txt:String) -> void:
	label_feedback.set_text(txt)
