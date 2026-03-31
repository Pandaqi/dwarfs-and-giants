class_name PuzzleGrid

var grid : Array
var cells : Array[PuzzleCell]
var size : Vector2i

var creation_callback : Callable = func(pos:Vector2i): return PuzzleCell.new(pos)

enum NeighborMode
{
	NONE,
	HORIZONTAL,
	VERTICAL,
	DIAGONAL,
	ORTHOGONAL,
	ALL
}

var neighbor_mode := NeighborMode.ORTHOGONAL
var neighbor_directions : Dictionary[NeighborMode, Array] = {
	NeighborMode.NONE: [],
	NeighborMode.HORIZONTAL: [Vector2i.LEFT, Vector2i.RIGHT],
	NeighborMode.VERTICAL: [Vector2i.UP, Vector2i.DOWN],
	NeighborMode.DIAGONAL: [Vector2i(-1,-1), Vector2i(1,-1), Vector2i(1,1), Vector2i(-1,1)],
	NeighborMode.ORTHOGONAL: [Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT, Vector2i.UP],
	NeighborMode.ALL: [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN, Vector2i(-1,-1), Vector2i(1,-1), Vector2i(1,1), Vector2i(-1,1)],
}

func create(new_size:Vector2i) -> void:
	size = new_size
	
	grid = []
	cells = []
	
	grid.resize(size.x)
	for x in range(size.x):
		grid[x] = []
		grid[x].resize(size.y)
		for y in range(size.y):
			var new_cell = creation_callback.call(Vector2i(x,y))
			grid[x][y] = new_cell
			cells.append(new_cell)
	
	create_neighbors()

func create_neighbors() -> void:
	if neighbor_mode == NeighborMode.NONE: return
	
	var dirs := get_neighbor_directions() 
	for cell in cells:
		cell.neighbors = []
		for dir in dirs:
			var pos := cell.pos + dir
			if is_out_of_bounds(pos): continue
			cell.neighbors.append(get_at(pos))

func get_neighbor_directions() -> Array[Vector2i]:
	var arr : Array[Vector2i] = []
	arr.assign(neighbor_directions[neighbor_mode])
	return arr

func get_at(pos:Vector2i) -> PuzzleCell:
	if is_out_of_bounds(pos): return null
	return grid[pos.x][pos.y]

func is_out_of_bounds(pos:Vector2i) -> bool:
	return pos.x < 0 or pos.x >= size.x or pos.y < 0 or pos.y >= size.y

func get_row(idx:int) -> Array[PuzzleCell]:
	var arr : Array[PuzzleCell] = []
	for x in range(size.x):
		arr.append(grid[x][idx])
	return arr

func get_column(idx:int) -> Array[PuzzleCell]:
	var arr : Array[PuzzleCell] = []
	arr.assign(grid[idx])
	return arr

func get_random_cell() -> PuzzleCell:
	return cells.pick_random()

func get_cells() -> Array[PuzzleCell]:
	return cells
