extends Node2D
class_name Cell

var data : CellData
var hovering := false
var tween_active : Tween

@export var sprite_base : Sprite2D
@export var type_sign : Sprite2D
@export var character : Node2D
@export var area : Area2D

@export var audio_clicked : AudioStreamPlayer2D
@export var audio_error : AudioStreamPlayer2D

signal clicked(c:Cell)
signal hovered(h:bool)

func _ready() -> void:
	area.mouse_entered.connect(_on_mouse_entered)
	area.mouse_exited.connect(_on_mouse_exited)
	area.input_event.connect(_on_input_event)
	
	var terrain_type := PuzzleFramework.puzzle_seed % 4
	sprite_base.set_frame(terrain_type*4 + randi_range(0,3))
	
	hovered.connect(character._on_hovered)
	
	type_sign.position.x += randf_range(-1,1) * 4.0
	type_sign.rotation = randf_range(-1,1) * 0.025 * PI

func revive() -> void:
	if tween_active: PuzzleTween.force_tween_completion(tween_active)
	tween_active = PuzzleTween.play_popup_tween(self)

func destroy() -> void:
	tween_active = PuzzleTween.play_popdown_tween(self)

func _on_mouse_entered() -> void:
	hovering = true
	hovered.emit(hovering)

func _on_mouse_exited() -> void:
	hovering = false
	hovered.emit(hovering)

func _process(dt:float) -> void:
	animate_hover(dt)

func animate_hover(dt:float) -> void:
	if tween_active and tween_active.is_running(): return
	
	# @NOTE: keep scale small enough that the cell never overlaps another cell as that would cause z-index/ordering issues and that's meh
	var target_scale := Vector2.ONE*1.1 if hovering else Vector2.ONE
	sprite_base.set_scale(sprite_base.scale.lerp(target_scale, 10*dt))

func sync_to_data(d:CellData) -> void:
	data = d
	data.changed.connect(_on_data_changed)
	_on_data_changed()

func _on_data_changed() -> void:
	type_sign.set_visible(data.has_type() and PuzzleSettings.get_value("show_type_signs"))
	type_sign.set_frame(0 if data.is_dwarf() else 1)
	if data.is_giant(): type_sign.position.x = absf(type_sign.position.x)
	
	character.refresh_from_data(data)

func _on_input_event(_vp:Viewport, ev:InputEvent, _shape_idx:int) -> void:
	if not (ev is InputEventMouseButton or ev is InputEventScreenTouch): return
	if ev.is_pressed(): return
	PuzzleAudio.play_audio_nice(audio_clicked)
	clicked.emit(self)

func on_illegal_move() -> void:
	PuzzleAudio.play_audio_nice(audio_error)
	PuzzleTween.play_wiggle_tween(sprite_base)
	# @TODO: play error audio
