extends CanvasLayer
class_name PuzzleTutorial

@export var background : CanvasLayer
@export var background_anchor := Vector2(0.25, 0.5)
@export var background_scale := 1.0

@export var foreground : CanvasLayer
@export var foreground_anchor := Vector2(0.5, 0.5)
@export var foreground_scale := 1.0

@export var container_2d : Node2D

var stages : Array[PuzzleTutorialStage]
var stage_index := -1
var audio_player : AudioStreamPlayer
var timer : Timer

@export var pointer_scene := preload("res://puzzle-framework/tutorial/click-tap-indicator.tscn")
var pointer : Node2D


## Populate this list with the right objects after creating/visualizing the puzzle
## (Example: fill it with the object to click for every turn of the solution, so that tutorial stages can directly reference them)
## (Example: fill it with the major UI elements so tutorial stages can highlight and explain them)
var objects_focus : Array[Node2D] = []

signal start_reached()
signal end_reached()

func _enter_tree() -> void:
	if not PuzzleSettings.get_value("show_tutorial"): return
	
	# listen to the signal that the tutorial can start
	PuzzleFramework.puzzle_started.connect(_on_puzzle_started)

func initialize() -> void:
	# grab and filter stages
	stages = PuzzleSettings.get_difficulty().tutorial.duplicate(false)
	for i in range(stages.size() -1, -1, -1):
		if stages[i].is_valid(): continue
		stages.remove_at(i)
	
	# decide final containers for new objects
	if not background: background = self
	if not foreground: foreground = self
	
	# create the basic pointer we'll often need
	if pointer_scene and container_2d:
		pointer = pointer_scene.instantiate()
		container_2d.add_child(pointer)
		pointer.hide()
	
	# used for narrating the tutorial
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	
	# used for timed transitions/delays between stages
	timer = Timer.new()
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)

func set_focus_objects(obj:Array[Node2D]) -> void:
	objects_focus = obj

func get_focus_object(idx:int) -> Node2D:
	return objects_focus[idx]

func focus_pointer(obj:Node2D) -> Tween:
	# obj.get_global_transform_with_canvas().origin
	return PuzzleTween.play_pointer_tween(pointer, obj.global_position)

func count_stages() -> int:
	return stages.size()

func play_audio(a:AudioStream) -> void:
	audio_player.stream = a
	audio_player.play()

func _on_puzzle_started() -> void:
	initialize()
	goto_next_stage()

func get_current_stage() -> PuzzleTutorialStage:
	return stages[stage_index]

func goto_next_stage() -> void:
	stage_index = clampi(stage_index + 1, -1, count_stages())

	if stage_index == -1:
		start_reached.emit()
		return
	
	if stage_index >= count_stages():
		finish()
		return
	
	print("Activating current stage", stage_index)
	var stage := get_current_stage()
	stage.activate(self)

func finish() -> void:
	end_reached.emit()
	
	# make sure we deactivate any stages still active when the tutorial is over
	for stage in stages:
		if not stage.is_active(): return
		stage.deactivate()

func start_timer(dur:float) -> void:
	timer.wait_time = dur
	timer.start()

func _on_stage_finished() -> void:
	goto_next_stage()

func _on_timer_timeout() -> void:
	goto_next_stage()

func get_position_in_viewport(pos:Vector2) -> Vector2:
	var rect := get_viewport().get_visible_rect()
	return rect.position + pos * rect.size

func add_to_background(t:Texture2D) -> Sprite2D:
	var s := Sprite2D.new()
	s.texture = t
	background.add_child(s)
	s.set_position(get_position_in_viewport(background_anchor))
	s.set_scale(Vector2.ONE * background_scale)
	return s

func add_to_foreground(t:Texture2D) -> Sprite2D:
	var s := Sprite2D.new()
	s.texture = t
	foreground.add_child(s)
	s.set_position(get_position_in_viewport(foreground_anchor))
	s.set_scale(Vector2.ONE * foreground_scale)
	return s
