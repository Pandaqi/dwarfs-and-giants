extends PuzzleSetting
class_name PuzzleSettingText

@export var alignment : HorizontalAlignment = HORIZONTAL_ALIGNMENT_CENTER
@export var min_length := 3
@export var max_length := 16
@export var force_alphanumeric := true

var line_edit : LineEdit

func create_nodes(container:Control) -> void:
	line_edit = LineEdit.new()
	line_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.add_child(line_edit)
	line_edit.alignment = alignment
	line_edit.placeholder_text = label
	line_edit.text_changed.connect(_on_value_changed)
	line_edit.tooltip_text = tooltip
	
	write(value)
	value = read()

func _on_value_changed(val:String) -> void:
	value = val
	super.on_value_changed()

func write(val:Variant) -> void:
	if val == null: val = default
	value = str(val)
	line_edit.text = value
	super.write(val)

func read() -> Variant:
	return line_edit.text

func enable() -> void:
	line_edit.editable = true

func disable() -> void:
	line_edit.editable = false

# Matches any non-alphanumeric character
# So if the search result is Nnull, it means the string has no bad characters
func has_only_alphanumeric_characters(s:String) -> bool:
	var regex := RegEx.create_from_string("[^A-Za-z0-9]")
	return regex.search(s) == null

func validate() -> String:
	if value.length() < min_length: return "Invalid input (too short)"
	if value.length() > max_length: return "Invalid input (too long)"
	if force_alphanumeric and not has_only_alphanumeric_characters(value): return "Invalid input (only letters / numbers allowed)"
	return ""
