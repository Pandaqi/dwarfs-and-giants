extends PuzzleCell
class_name CellData

enum Type
{
	NONE,
	DWARF,
	GIANT
}

const SIZE_UNTOUCHED = -1000

var size_bounds := Vector2i.ZERO
var size_max := -1000
var size_min := 1000
var size := SIZE_UNTOUCHED
var type := Type.NONE

static func get_random_type() -> Type:
	return Type.DWARF if randf() <= 0.5 else Type.GIANT

func has_type() -> bool:
	return type != Type.NONE

func get_type() -> Type:
	return type

func set_random_type() -> void:
	set_type(get_random_type())

func remove_type() -> Type:
	var old_type := type
	set_type(Type.NONE)
	return old_type

func set_type(tp:Type) -> void:
	type = tp
	changed.emit()

func is_dwarf() -> bool:
	return type == Type.DWARF

func is_giant() -> bool:
	return type == Type.GIANT

func has_untouched_size() -> bool:
	return size == SIZE_UNTOUCHED

func get_size() -> int:
	return size

func get_size_as_ratio() -> float:
	return (size - size_bounds.x) / float(size_bounds.y - size_bounds.x)

func set_random_size(bds:Vector2i) -> void:
	set_size_bounds(bds)
	set_size(randi_range(bds.x, bds.y))

func set_size_bounds(bds:Vector2i) -> void:
	size_bounds = bds

func change_size(ds:int) -> void:
	set_size(size + ds)

func change_size_force(ds:int) -> void:
	size += ds

func set_size(s:int) -> void:
	size = s
	size_min = mini(size, size_min)
	size_max = maxi(size, size_max)
	changed.emit()

func is_at_smallest_size() -> bool:
	return size == size_bounds.x

func is_at_largest_size() -> bool:
	return size == size_bounds.y

func is_at_maximum_size() -> bool:
	return is_at_smallest_size() or is_at_largest_size()

func is_illegal_size() -> bool:
	return size < size_bounds.x or size > size_bounds.y
