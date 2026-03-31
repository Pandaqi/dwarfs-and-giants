extends Control
class_name PuzzleMenuBackground

@export var pattern_container : Control
@export var background : ColorRect
@export var pattern : ColorRect

func _ready() -> void:
	pattern_container.set_visible(PuzzleFramework.menu_pattern_enabled)
	
	background.color = PuzzleFramework.menu_background_color
	pattern.material.set_shader_parameter("circle_color", PuzzleFramework.menu_pattern_color)
