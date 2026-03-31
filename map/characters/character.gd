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
@export var particles_resize : CPUParticles2D

const DWARF_FRAMES : Array[int] = [0,1,2] # frame 3???
const GIANT_FRAMES : Array[int] = [4,5,6,7]

const DWARF_OUTLINE_COLOR := Color.RED
const GIANT_OUTLINE_COLOR := Color.BLUE

var data : CellData
var was_visible := true
var old_size := -1
var scale_bounds := Vector2(0.225, 0.9)
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

func refresh_from_data(cd:CellData) -> void:
	data = cd
	
	if tween_active: PuzzleTween.force_tween_completion(tween_active)
	
	if not data.has_type(): 
		if was_visible: tween_active = PuzzleTween.play_popdown_tween(self)
		was_visible = false
		return
	
	if not was_visible:
		tween_active = PuzzleTween.play_popup_tween(self)
	
	var frames : Array[int] = DWARF_FRAMES if data.is_dwarf() else GIANT_FRAMES
	var frame := frames[PuzzleFramework.puzzle_seed % frames.size()]
	if not PuzzleSettings.get_value("use_varying_sprites"): frame = frames[0]
	sprite.set_frame(frame)
	
	refresh_outline()
	
	var tween_resize := old_size != -1 and data.size != old_size
	var new_scale := lerpf(scale_bounds.x, scale_bounds.y, data.get_size_as_ratio())
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
	label_number.set_text(str(old_size))
