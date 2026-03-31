extends PuzzleSetting
class_name PuzzleSettingSlider

@export var min_value : float = 0.0
@export var max_value : float = 10.0
@export var step_size : float = 1.0

@export var feedback_unit : String = ""
@export var feedback_rounded : bool = true

var slider : HSlider
var fb : Label

func create_nodes(container:Control) -> void:
	var subcont := HBoxContainer.new()
	subcont.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	subcont.tooltip_text = tooltip
	container.add_child(subcont)
	
	fb = Label.new()
	fb.custom_minimum_size.x = 48.0
	subcont.add_child(fb)
	
	slider = HSlider.new()
	subcont.add_child(slider)
	slider.min_value = min_value
	slider.max_value = max_value
	slider.step = step_size
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	subcont.add_child(create_header_node())
	
	slider.value_changed.connect(_on_value_changed)
	write(value)
	value = read()

func _on_value_changed(val:float) -> void:
	value = val
	update_feedback_text()
	super.on_value_changed()

func write(val:Variant) -> void:
	if val == null: val = default
	if not (val is float or val is int): val = float(val)
	value = val
	slider.value = val
	update_feedback_text()

func update_feedback_text() -> void:
	var val_fb := str(roundi(value)) if feedback_rounded else str(value)
	fb.set_text(val_fb + feedback_unit)

func read() -> Variant:
	return slider.value

func enable() -> void:
	slider.editable = true

func disable() -> void:
	slider.editable = false

func update_bounds(min_val:float, max_val:float) -> void:
	slider.min_value = min_val
	slider.max_value = max_val
