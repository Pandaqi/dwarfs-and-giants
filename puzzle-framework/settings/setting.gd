extends Resource
class_name PuzzleSetting

## Unique id used to read and write this setting globally
@export var key : String

## Human readable text/explanation for the setting
@export var label : String

## The default value that the setting starts with
@export var default : Variant

## A tooltip to explain the setting when the user hovers over it
@export var tooltip : String

## Custom code run whenever the value is changed (to immediately apply some complex effect)
@export_multiline var callback : String

var value : Variant

signal value_changed(s:PuzzleSetting)

## Adds the proper nodes for reading + updating this setting to the container passed in
func create_nodes(_container:Control) -> void:
	pass

## Create the label node to indicate what the setting is
func create_header_node() -> Label:
	var text := Label.new()
	text.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.custom_minimum_size = Vector2(128.0, 0)  # @TODO: make this size configurable somehow, pull it out into ALL settings?
	text.set_text(label)
	return text

## Forcefully set the input to the given value
func write(_val:Variant) -> void:
	pass

func on_value_changed() -> void:
	value_changed.emit(self)
	run_custom_callback()

func get_value_safe() -> Variant:
	if value != null: return value
	if default != null: return default
	return false

## Read the current value
func read() -> Variant:
	return false

## Allows the input to be changed by the user
func enable() -> void:
	pass

## Disallows the input to be changed by the user
func disable() -> void:
	pass

## Validates the input; returns the error message if something's wrong
func validate() -> String:
	return ""

## Puts our custom code into a fake new script, then runs that
func run_custom_callback() -> void:
	if not callback: return
	
	var source_code := """
@warning_ignore_start('unused_parameter')
@warning_ignore_start('narrowing_conversion')
func eval(setting):
{code}
""".format({ code = indent_callback_string(callback) })
	var script = GDScript.new()
	script.set_source_code(source_code)
	script.reload()
	
	var ref = RefCounted.new()
	ref.set_script(script)
	ref.eval(self)

## Helper function to give callback scripts proper indentation
func indent_callback_string(cb:String) -> String:
	cb = cb.replace("\r", "")
	var callback_lines = cb.split("\n")
	for i in range(callback_lines.size()):
		callback_lines[i] = "\t" + callback_lines[i]
	return "\n".join(callback_lines)
