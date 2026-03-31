extends PuzzleSetting
class_name PuzzleSettingCheckbox

var checkbox : CheckBox

func create_nodes(container:Control) -> void:
	var subcont := HBoxContainer.new()
	subcont.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	subcont.tooltip_text = tooltip
	container.add_child(subcont)
	
	checkbox = CheckBox.new()
	subcont.add_child(checkbox)
	checkbox.toggle_mode = true
	checkbox.toggled.connect(_on_value_changed)
	
	write(value)
	value = read()
	
	var header := create_header_node()
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	subcont.add_child(header)

func _on_value_changed(val:bool) -> void:
	value = val
	super.on_value_changed()

func write(val:Variant) -> void:
	if val == null: val = default
	if val is bool: 
		checkbox.button_pressed = val
		return
	
	if val is String:
		checkbox.button_pressed = (val == "true")
		return
	
	if (val is float) or (val is int):
		checkbox.button_pressed = not is_zero_approx(val)
		return
	
	checkbox.button_pressed = false

func read() -> Variant:
	return checkbox.button_pressed

func enable() -> void:
	checkbox.disabled = false

func disable() -> void:
	checkbox.disabled = true
