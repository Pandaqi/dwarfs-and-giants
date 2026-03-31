extends PuzzleSetting
class_name PuzzleSettingDropdown

@export var options : Array[String]

var dropdown : OptionButton

func create_nodes(container:Control) -> void:
	var subcont := HBoxContainer.new()
	subcont.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	subcont.tooltip_text = tooltip
	container.add_child(subcont)
	
	dropdown = OptionButton.new()
	subcont.add_child(dropdown)
	
	subcont.add_child(create_header_node())
	
	dropdown.allow_reselect = true
	for option in options:
		dropdown.add_item(option)
	dropdown.item_selected.connect(_on_value_changed)
	
	write(value)
	value = read()

func _on_value_changed(idx:float) -> void:
	value = options[idx]
	super.on_value_changed()

func write(val:Variant) -> void:
	if val == null: val = default
	var idx := maxi(options.find(val), 0)
	dropdown.select(idx)

func read() -> Variant:
	return dropdown.get_item_text(dropdown.selected)

func enable() -> void:
	dropdown.disabled = false

func disable() -> void:
	dropdown.disabled = true
