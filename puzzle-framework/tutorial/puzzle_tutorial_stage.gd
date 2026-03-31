extends Resource
class_name PuzzleTutorialStage

enum Transition
{
	NONE,
	WAIT_UNTIL_COMPLETION,
	DELAY_SECONDS,
	WAIT_USER_ACTION
}

## whether it's currently showing/doing stuff or not
var active := false

## things to display and then remove when this stage ends
var static_elements : Array[Variant] = []

## animations and transitions that all need to complete/finish before we continue
var dynamic_elements : Array[Variant] = []
var dynamic_elements_done := 0

## easy reference to live node/object we've marked as our focus
var object_focus : Node2D

@export var audio : AudioStream
@export var image_background : Texture2D
@export var image_foreground : Texture2D

## how we transition into the next stage (wait X seconds, don't wait, etc)
@export var transition := Transition.WAIT_UNTIL_COMPLETION
@export var duration := 0.0

## our custom game can set a list of objects to focus on
## (these are references to live nodes, such as the cells to click for the solution)
## stages can focus on the right one through setting its index in the list here!
@export var object_focus_index := -1

## if true, it uses the default pointer image and pointer tween on the focus object
## if false, you need custom code to decide what you want to do with it
@export var object_focus_is_pointer := false

## whether it should automatically be removed when tutorial is done cycling through its stages
## or stay around forever as you play
@export var persistent := false

@export var hide_after_x_attempts := 0
@export var hide_after_x_retries := 3
@export var hide_after_x_attempts_at_difficulty := 3

## Any custom GDScript code to run in/on this stage
## Arguments passed in are (pt:PuzzleTutorial, pts:PuzzleTutorialStage)
@export_multiline("String") var callback = ""

signal started()
signal finished()

func activate(pt:PuzzleTutorial) -> void:
	active = true
	started.emit()
	
	static_elements = []
	
	dynamic_elements = []
	dynamic_elements_done = 0
	
	if audio:
		register_dynamic_element(pt.audio_player)
		pt.play_audio(audio)
	
	if image_background:
		var sprite := pt.add_to_background(image_background)
		register_static_element(sprite)
	
	if image_foreground:
		var sprite := pt.add_to_foreground(image_foreground)
		register_static_element(sprite)
	
	if object_focus_index != -1:
		object_focus = pt.get_focus_object(object_focus_index)
		if object_focus_is_pointer:
			var tw := pt.focus_pointer(object_focus)
			register_dynamic_element(tw)
	
	run_custom_callback(pt)
	
	plan_transition(pt)

func is_valid() -> bool:
	if hide_after_x_attempts > 0:
		if PuzzleFramework.num_attempts >= hide_after_x_attempts: return false
	
	if hide_after_x_retries > 0:
		if PuzzleFramework.num_attempts_same_puzzle >= hide_after_x_retries: return false
	
	if hide_after_x_attempts_at_difficulty > 0:
		if PuzzleFramework.get_num_attempts_current_difficulty() >= hide_after_x_attempts_at_difficulty: return false
	
	return true

func is_active() -> bool:
	return active

func register_static_element(elem:Variant) -> void:
	static_elements.append(elem)

func count_static_elements() -> int:
	return static_elements.size()

func count_dynamic_elements() -> int:
	return dynamic_elements.size()

func register_dynamic_element(elem:Variant) -> void:
	dynamic_elements.append(elem)
	
	if elem is AudioStreamPlayer:
		await elem.finished
		_on_dynamic_element_finished(elem)
	
	if elem is Tween:
		await elem.finished
		_on_dynamic_element_finished(elem)
	
	if elem is AnimationPlayer:
		await elem.animation_finished
		_on_dynamic_element_finished(elem)

func plan_transition(pt:PuzzleTutorial) -> void:
	if transition == PuzzleTutorialStage.Transition.WAIT_USER_ACTION:
		return
	
	if transition == PuzzleTutorialStage.Transition.NONE:
		pt.goto_next_stage()
		return
	
	if transition == PuzzleTutorialStage.Transition.WAIT_UNTIL_COMPLETION:
		finished.connect(pt._on_stage_finished)
	
	if transition == PuzzleTutorialStage.Transition.DELAY_SECONDS:
		pt.start_timer(duration)

func _on_dynamic_element_finished(_elem:Variant) -> void:
	if not active: return
	
	dynamic_elements_done += 1
	
	if dynamic_elements_done >= count_dynamic_elements():
		deactivate()

func deactivate() -> void:
	if persistent: return
	
	object_focus = null
	active = false
	
	dynamic_elements = []
	
	for elem in static_elements:
		elem.queue_free()
	static_elements = []
	
	finished.emit()

func indent_callback_string(cb:String) -> String:
	cb = cb.replace("\r", "")
	var callback_lines = cb.split("\n")
	for i in range(callback_lines.size()):
		callback_lines[i] = "\t" + callback_lines[i]
	return "\n".join(callback_lines)

func run_custom_callback(pt:PuzzleTutorial) -> void:
	if not callback: return
	
	var source_code := """
@warning_ignore_start('unused_parameter')
@warning_ignore_start('narrowing_conversion')
func eval(pt:PuzzleTutorial, pts:PuzzleTutorialStage):
{code}
""".format({ code = indent_callback_string(callback) })
	var script = GDScript.new()
	script.set_source_code(source_code)
	script.reload()
	
	var ref = RefCounted.new()
	ref.set_script(script)
	ref.eval(pt, self)
