extends Node2D
class_name SquasherStretcher

@export var node : Node2D
var counter := 0.0
@export var speed := Vector2.ONE * 5.0
@export var max_offset := Vector2(0.07, 0.07)
@export var max_rot := 0.03*PI
@export var randomization := 0.5

var paused := false

func _ready() -> void:
	max_offset.x *= get_randomization_factor()
	max_offset.y *= get_randomization_factor()
	max_rot *= get_randomization_factor()
	speed.x *= get_randomization_factor()
	speed.y *= get_randomization_factor()

func get_randomization_factor() -> float:
	return randf_range(1.0 - randomization, 1.0 + randomization)

func set_paused(val:bool) -> void:
	paused = val

func _physics_process(dt: float) -> void:
	if paused: return
	
	counter += dt
	
	node.rotation = sin(counter * speed.x) * max_rot
	node.scale = Vector2(1.0 + sin(counter * speed.x)*max_offset.x, 1.0 + cos(counter * speed.y)*max_offset.y)
