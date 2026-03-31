extends Node2D
class_name PuzzleVisualizer

var gen : PuzzleGenerator
var cell_size := 220.0
var commands : PuzzleCommands
var cells : Array[Cell]
var busy := false

@export var cell_scene : PackedScene
@export var cam : PuzzleCamera

func _ready() -> void:
	gen = PuzzleGenerator.new()
	gen.generate()
	visualize()

func convert_grid_pos_to_real_pos(pos:Vector2i) -> Vector2:
	return (Vector2(pos) + Vector2(0.5, 0.5)) * cell_size

func visualize() -> void:
	cells = []
	for cell_data in gen.grid.get_cells():
		var cell : Cell = cell_scene.instantiate()
		cell.set_position(convert_grid_pos_to_real_pos(cell_data.pos))
		add_child(cell)
		cells.append(cell)
		
		cell.sync_to_data(cell_data)
		cell.clicked.connect(_on_cell_clicked)
	
	cam.set_target(Rect2(Vector2.ZERO, gen.grid.size * cell_size))
	
	commands = PuzzleCommands.new()
	commands.prepare_for_play()
	commands.set_solution(gen.solution)
	commands.do_finished.connect(_on_commands_finished)

func is_valid_next_move(cell_clicked:Cell) -> bool:
	if not cell_clicked.data.has_type(): return false
	if gen.allow_any_order: return true
	
	# get all cells sorted
	var cells := gen.get_cells_sorted_correctly()
	if cells.size() <= 0: return false
	
	# find all cells that currently have the smallest size + proper type (if order matters)
	var cells_valid : Array[CellData] = []
	var smallest_size : int = cells.front().size
	var smallest_type : CellData.Type = cells.front().type
	for cell in cells:
		if cell.size > smallest_size: break
		if cell.type != smallest_type and gen.dwarfs_come_before_giants: break
		cells_valid.append(cell)
	
	# check if the clicked cell is among them!
	return cells_valid.has(cell_clicked.data)

func _on_cell_clicked(c:Cell) -> void:
	if commands.is_busy(): return
	if busy: return
	
	if not is_valid_next_move(c):
		c.on_illegal_move()
		return
	
	busy = true
	
	print("Cell Clicked!")
	commands.start_new_turn()
	await commands.execute_command(CommandTurn.new(c.data))

func _on_commands_finished() -> void:
	# check if we've lost (some dwarf/giant became too big)
	var cells_left := gen.get_cells_with_type()
	if gen.enforce_size_bounds:
		var we_lost := false
		for cell in cells_left:
			if cell.is_illegal_size():
				we_lost = true
				break
		if we_lost:
			await goto_game_over(false)
	
	# check if we've won (no cells left to click)
	var no_cells_left := cells_left.size() <= 0
	if no_cells_left:
		await goto_game_over(true)
	
	busy = false

func goto_game_over(we_won := false) -> void:
	# wait for the dying animation
	if not we_won: 
		await get_tree().create_timer(1.0).timeout
	
	PuzzleFramework.finish_puzzle(we_won)
	
	for cell in cells:
		cell.destroy()
