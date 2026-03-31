class_name PuzzleGenerator

var grid : PuzzleGrid
var commands : PuzzleCommands
var solution : Array[PuzzleCommand]

var grid_size := Vector2i(3,3)
var num_turns_bounds := Vector2i(5,7) # this is automatically also the number of characters in the puzzle
var cell_size_bounds := Vector2i(0,5)
var place_multiple_of_same_prob := 0.25

var dont_resize_when_not_needed := true
var dwarfs_come_before_giants := false
var dwarfs_shrink_neighbors := false
var giants_grow_neighbors := false
var enforce_size_bounds := false
var allow_any_order := false

func generate() -> void:
	PuzzleSettings.apply_difficulty_properties(self)
	
	var max_tries := 100
	for i in range(max_tries):
		print("PuzzleGenerator | Attempt " + str(i))
		create_grid()
		take_turns()
		var success := clean_up()
		if success: break

func create_grid() -> void:
	grid = PuzzleGrid.new()
	grid.creation_callback = func(pos:Vector2i): return CellData.new(pos)
	grid.neighbor_mode = PuzzleGrid.NeighborMode.ORTHOGONAL
	grid.create(grid_size)

func take_turns() -> void:
	## Step 1 = Place dwarfs and giants of random sizes. 
	## At the moment, their size is just a random integer that doesn't mean anything yet.
	var num_turns := randi_range(num_turns_bounds.x, num_turns_bounds.y)
	var empty_cells := grid.get_cells().duplicate(false)
	empty_cells.shuffle()
	
	var num_characters_placed := 0
	while num_characters_placed < num_turns:
		var num_to_place := 1
		if dwarfs_come_before_giants and randf() <= place_multiple_of_same_prob: num_to_place = 2
		
		num_to_place = mini(num_to_place, num_turns - num_characters_placed)
		num_characters_placed += num_to_place
		
		# we prefer placing multiple of the same type to force the player to pick the correct order (otherwise you might have only one choice anyway)
		# before shrink/grow happens, we place two different types on purpose to test "dwarfs come before giants"-logic
		var rand_size := randi_range(cell_size_bounds.x, cell_size_bounds.y)
		for i in range(num_to_place):
			var tp := CellData.get_random_type()
			if dwarfs_shrink_neighbors and not giants_grow_neighbors:
				tp = CellData.Type.DWARF
			if giants_grow_neighbors and not dwarfs_shrink_neighbors:
				tp = CellData.Type.GIANT
			if (not dwarfs_shrink_neighbors) and (not giants_grow_neighbors):
				tp = CellData.Type.DWARF if (i == 0) else CellData.Type.GIANT
			if num_to_place == 1:
				tp = CellData.get_random_type()
			
			var cell : CellData = empty_cells.pop_back()
			cell.set_size_bounds(cell_size_bounds)
			cell.set_size(rand_size)
			cell.set_type(tp)
	
	## Step 2 = Take turns simply following the one rule (smallest -> largest)
	## (By shuffling before sorting, we take a random one of the smallest if there are multiple)
	commands = PuzzleCommands.new()
	solution = []
	for i in range(num_turns):
		var correct_cell : CellData = get_cells_sorted_correctly().front()
		var cmd := CommandTurn.new(correct_cell)
		
		commands.start_new_turn()
		commands.execute_command(cmd)
		solution.append(cmd)

func get_cells_with_type() -> Array[CellData]:
	var arr : Array[CellData] = []
	arr.assign(grid.get_cells().filter(func(c:CellData): return c.has_type()))
	return arr

func get_cells_sorted_correctly() -> Array[CellData]:
	var cells_sorted := get_cells_with_type()
	cells_sorted.shuffle()
	if allow_any_order: return cells_sorted
	
	cells_sorted.sort_custom(func(a:CellData, b:CellData):
		# if same size, make dwarfs come before giants
		if (a.size == b.size) and dwarfs_come_before_giants and a.type != b.type:
			if a.is_dwarf() and b.is_giant(): return true
			return false
		# otherwise just sort ascending based on size
		return a.size < b.size
		)
	return cells_sorted

func get_cells_used() -> Array[CellData]:
	var arr : Array[CellData] = []
	arr.assign(grid.get_cells().filter(func(c:CellData): return not c.has_untouched_size()))
	return arr

func get_cells_compared_to_bounds(type := "below") -> Array[CellData]:
	var cells_used := get_cells_used()
	var arr : Array[CellData] = []
	for cell in cells_used:
		if type == "below" and cell.size_min < cell_size_bounds.x:
			arr.append(cell)
		if type == "above" and cell.size_max > cell_size_bounds.y:
			arr.append(cell)
	return arr

func get_max_dist_to_size_bound(type := "below", cells:Array[CellData] = []) -> int:
	var dist := 1000
	for cell in cells:
		var dist_cell := 0
		if type == "below": 
			dist_cell - cell_size_bounds.x - cell.size_min
		if type == "above":
			dist_cell = cell.size_max - cell_size_bounds.y
		dist = maxi(dist, dist_cell)
	return dist

func calibrate_sizes() -> bool:
	var min_size := 1000
	var max_size := -1000
	var cells_used := get_cells_used()
	var cells_by_size : Dictionary[int, Array] = {}
	for cell in cells_used:
		min_size = mini(cell.size_min, min_size)
		max_size = maxi(cell.size_max, max_size)
		
		if not (cell.get_size() in cells_by_size): cells_by_size[cell.get_size()] = []
		cells_by_size[cell.get_size()].append(cell)
	
	var should_resize := not (dont_resize_when_not_needed and is_within_bounds(min_size, cell_size_bounds) and is_within_bounds(max_size, cell_size_bounds))
	if not should_resize: return true
	
	print("PuzzleGenerator | Needs Recalibrating | ", min_size, " | ", max_size)
	
	# check anything BELOW our bound that needs to be pushed up
	# essentially, it all gets pushed to the same level so that the player has to find the order
	var cells_below := get_cells_compared_to_bounds("below")
	for cell in cells_below:
		cell.change_size(cell_size_bounds.x - cell.size_min)
		if cell.is_illegal_size(): return false
	
	# check anything ABOVE our bound that needs to be pushed down
	var cells_above := get_cells_compared_to_bounds("above")
	for cell in cells_above:
		cell.change_size(cell_size_bounds.y - cell.size_max)
		if cell.is_illegal_size(): return false
	
	return true

func clean_up() -> bool:
	## Step 3 = Check the biggest and the smallest size we've made
	## We "recalibrate" by squashing all sizes to fit that range
	## (We basically pretend the size was different all along so the final solution fits inside our bounds; These new values will still be in the right ORDER because they're linearly squashed)
	var result := calibrate_sizes()
	if not result: return false
	
	## Step 4 = we UNDO all our commands from generation to bring the puzzle back to its original state
	while commands.has_turns():
		commands.undo_last_turn()
	
	return true

func is_within_bounds(val:int, bds:Vector2i) -> bool:
	return val >= bds.x and val <= bds.y


	
## @NOTE: The squash start + ratio must be identical for all cells
## Or we get changes in order anyway. See example.
## Example) Two cells: (-2,2) and (4,7). We want to map it to (0,5)
## size_ratio = 5 / (7 - -2) = 5/9
## size_add = 0 - (-2) = 2
## cell1 = (-2,2) + 2 = (0,4) x (5/9) = (0, 20/9) = (0,2)
## cell2 = (4,7) + 2 = (6,9) x (5/9) = (30/9, 45/9) = (3,5)
#var size_ratio := (cell_size_bounds.y - cell_size_bounds.x) / float(max_size - min_size)
#var size_add := cell_size_bounds.x - min_size
#
#for cell in cells_used:
	#var new_size : int = floori(size_add + cell.size * size_ratio)
	#cell.set_size(new_size)
