extends RefCounted
class_name PuzzleCell

var pos : Vector2i
var neighbors : Array[PuzzleCell]
var connections : Array[PuzzleConnection]
var connection_cells : Dictionary[PuzzleCell, PuzzleConnection]

signal changed()

func _init(p:Vector2i) -> void:
	pos = p
	neighbors = []
	connections = []

func count_neighbors() -> int:
	return neighbors.size()

func get_neighbors() -> Array[PuzzleCell]:
	return neighbors

# we need this silly helper function because of GDScript type-check + shuffle return value limitations
func get_neighbors_shuffled() -> Array[PuzzleCell]:
	var arr : Array[PuzzleCell] = []
	arr.assign(neighbors)
	arr.shuffle()
	return arr

func count_connections() -> int:
	return connections.size()

func add_connection(c:PuzzleConnection) -> void:
	connections.append(c)
	connection_cells[c.get_other(self)] = c

func remove_connection(c:PuzzleConnection) -> void:
	connections.erase(c)
	connection_cells.erase(c.get_other(self))

func get_connection_to(c:PuzzleCell) -> PuzzleConnection:
	if not has_connection_to(c): return null
	return connection_cells[c]

func has_connection_to(c:PuzzleCell) -> bool:
	return (c in connection_cells)
