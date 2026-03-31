extends Node2D
class_name Character

@export var sprite_container : Node2D
@export var sprite : Sprite2D
@export var sprite_shadow : Sprite2D
@export var squasher_stretcher : SquasherStretcher
@export var anim_player : AnimationPlayer
@export var label_number : Label

@export var audio_resize : AudioStreamPlayer2D
@export var audio_illegal_size : AudioStreamPlayer2D
@export var audio_collected_dwarf : AudioStreamPlayer2D
@export var audio_collected_giant : AudioStreamPlayer2D
@export var particles_resize : CPUParticles2D

const DWARF_FRAMES : Array[int] = [0,1,2] # frame 3???
const GIANT_FRAMES : Array[int] = [4,5,6,7]

const DWARF_OUTLINE_COLOR := Color.RED
const GIANT_OUTLINE_COLOR := Color.BLUE

var data : CellData
var was_visible := true
var last_known_type := CellData.Type.NONE
var old_size := -1
var scale_bounds := Vector2(0.225, 0.9)
var scale_bounds_extremes := Vector2(0.175, 1.05) # for TOO SMALL and TOO BIG moments
var tween_active : Tween
var hovered := false

func _ready() -> void:
	sprite.material = sprite.material.duplicate(false)
	label_number.set_visible(PuzzleSettings.get_value("show_size_numbers"))

func _on_hovered(h:bool) -> void:
	hovered = h
	refresh_outline()

func refresh_outline() -> void:
	var base_color := DWARF_OUTLINE_COLOR if data.is_dwarf() else GIANT_OUTLINE_COLOR
	if hovered: base_color = Color.GREEN
	sprite.material.set_shader_parameter("color", base_color)

func get_voice_audio_player() -> AudioStreamPlayer2D:
	return audio_collected_dwarf if (last_known_type == CellData.Type.DWARF) else audio_collected_giant

func has_been_used() -> bool:
	return old_size != -1

func on_collected() -> void:
	tween_active = PuzzleTween.play_popdown_tween(self)
	if has_been_used():
		PuzzleAudio.play_audio_nice(get_voice_audio_player())

func refresh_from_data(cd:CellData) -> void:
	data = cd
	
	if tween_active: PuzzleTween.force_tween_completion(tween_active)
	
	if not data.has_type(): 
		if was_visible: on_collected()
		was_visible = false
		return
	
	if not was_visible:
		tween_active = PuzzleTween.play_popup_tween(self)
	
	last_known_type = data.type
	
	var frames : Array[int] = DWARF_FRAMES if data.is_dwarf() else GIANT_FRAMES
	var frame := frames[PuzzleFramework.puzzle_seed % frames.size()]
	if not PuzzleSettings.get_value("use_varying_sprites"): frame = frames[0]
	sprite.set_frame(frame)
	
	refresh_outline()
	
	var tween_resize := old_size != -1 and data.size != old_size
	var size_ratio := data.get_size_as_ratio()
	var new_scale := lerpf(scale_bounds.x, scale_bounds.y, size_ratio)
	if size_ratio < 0.0: new_scale = scale_bounds_extremes.x
	if size_ratio > 1.0: new_scale = scale_bounds_extremes.y
	
	if tween_resize:
		PuzzleAudio.play_audio_nice(audio_resize)
		particles_resize.set_emitting(true)
		tween_active = PuzzleTween.play_resize_tween(sprite_container, Vector2.ONE * new_scale)
	else:
		sprite_container.set_scale(Vector2.ONE * new_scale)
	
	sprite_shadow.set_scale(Vector2(1.0, 0.3) * 1.05 * new_scale)
	anim_player.stop()
	squasher_stretcher.set_paused(false)
	
	var enforce_max_size : bool = PuzzleSettings.get_difficulty_property("enforce_size_bounds")
	
	if data.is_at_maximum_size() and enforce_max_size:
		anim_player.play("at_max_size")
	
	if data.is_illegal_size() and enforce_max_size:
		squasher_stretcher.set_paused(true)
		audio_illegal_size.play()
		anim_player.play("at_illegal_size")
	
	was_visible = true
	old_size = data.get_size()
	label_number.set_text(str(old_size + 1))
