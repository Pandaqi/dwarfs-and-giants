extends Node2D
class_name PuzzleMenu

@export var button_container : VBoxContainer
@export var button_scene : PackedScene
@export var background : Control
@export var menu_container : Control
@export var pattern : ColorRect
@export var credits : Label
@export var heading : Label
@export var icon : TextureRect

@export var button_back : TextureButton

@export var button_settings : TextureButton
@export var settings : PuzzleSettingsVisualizer

func _ready() -> void:
	animate_heading()
	create_buttons()
	
	get_viewport().size_changed.connect(_on_size_changed)
	_on_size_changed()
	
	settings.toggled.connect(_on_settings_toggled)
	
	button_back.pressed.connect(_on_button_back_pressed)
	button_settings.pressed.connect(_on_button_settings_pressed)
	
	heading.add_theme_font_override("font", PuzzleFramework.font_heading)
	heading.set_text(PuzzleFramework.game_name)
	
	if OS.get_name() == "html5":
		button_back.hide()
	
	if not PuzzleSettings.has_settings():
		button_settings.hide()
	
	credits.set_text("{game_name} v{game_version} | {game_tagline} | {creator_credit}".format({
		"game_name": PuzzleFramework.game_name,
		"game_version": PuzzleFramework.game_version,
		"game_tagline": PuzzleFramework.game_tagline,
		"creator_credit": PuzzleFramework.creator_credit
	}))
	
	if PuzzleFramework.favicon != "":
		icon.texture = load("res://" + PuzzleFramework.favicon)
	
	if PuzzleFramework.menu_scene_custom:
		add_child(PuzzleFramework.menu_scene_custom.instantiate())

func _on_button_back_pressed() -> void:
	if settings.is_visible(): 
		_on_button_settings_pressed()
		return
	get_tree().quit()

func _on_button_settings_pressed() -> void:
	settings.toggle_active()

func _on_settings_toggled(active:bool) -> void:
	menu_container.set_visible(not active)

func _on_size_changed() -> void:
	pattern.material.set_shader_parameter("viewport_size", get_viewport_rect().size)

func animate_heading() -> void:
	var tw := get_tree().create_tween().set_ease(Tween.EASE_OUT)
	var dur := randf_range(0.2, 0.4)
	heading.modulate.a = 0.0
	tw.tween_property(heading, "modulate:a", 1.0, dur)

func create_buttons() -> void:
	var diffs : Array[PuzzleDifficulty] = PuzzleFramework.difficulties
	var tween_interval := 0.0
	for diff in diffs:
		var btn : PuzzleMenuButton = button_scene.instantiate()
		btn.sync_difficulty(diff)
		button_container.add_child(btn)
		btn.pressed.connect(func():
			PuzzleFramework.load_new_puzzle(diff.difficulty)
		)
		
		var tw := get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
		var dur := randf_range(0.4, 0.6)
		tw.tween_interval(tween_interval)
		tween_interval += 0.5*dur
		btn.modulate.a = 0.0
		tw.tween_property(btn, "modulate:a", 1.0, dur)
