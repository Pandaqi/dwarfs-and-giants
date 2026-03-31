extends Camera2D
class_name PuzzleCamera

@export var target : Rect2
@export var smooth_speed := 5.0
@export var edge_margin := Vector2(32.0, 32.0)

func set_target(new_target:Rect2) -> void:
	var update_instantly := !target
	target = new_target
	if update_instantly: set_position(target.get_center())

func _physics_process(dt: float) -> void:
	if not target: return
	
	var vp := get_viewport_rect().size - Vector2.ONE*2*edge_margin
	var desired_zoom := vp / target.size
	var uniform_zoom := Vector2.ONE * minf(desired_zoom.x, desired_zoom.y)
	set_zoom(zoom.lerp(uniform_zoom, smooth_speed*dt))
	
	var desired_position := target.get_center()
	set_position(get_position().lerp(desired_position, smooth_speed*dt))
