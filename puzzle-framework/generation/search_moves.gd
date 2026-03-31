extends Node
class_name PuzzleSearchMoves


var callback_moves : Callable
var callback_success : Callable
var callback_state_hash : Callable
var num_solutions_wanted := 1
var max_depth := 5
var commands : PuzzleCommands

var states_already_visited : Array[String]
var solutions : Array

func get_all_moves(cur_depth:int) -> Array[PuzzleCommand]:
	return callback_moves.call(cur_depth)

func get_state_hash() -> String:
	return callback_state_hash.call()

func is_success() -> bool:
	return callback_success.call()

func is_satisfied() -> bool:
	return solutions.size() >= num_solutions_wanted

func search() -> Array:
	if not commands: commands = PuzzleCommands.new()
	states_already_visited = []
	solutions = []
	search_recursive()
	return solutions

func search_recursive(cur_depth := 0) -> void:
	if is_satisfied(): return
	
	var moves_to_try : Array[PuzzleCommand] = get_all_moves(cur_depth)
	for move in moves_to_try:
		if is_satisfied(): break
		
		var new_command : PuzzleCommand = moves_to_try.pop_back()
		commands.start_new_turn()
		commands.execute_command(new_command)
		
		# if we've found a solution, no use searching further
		var search_further := true
		if is_success():
			solutions.append(commands.history.duplicate(false))
			search_further = false
		
		# if we've exhausted our depth, stop as well
		if cur_depth >= max_depth:
			search_further = false
		
		# if we've seen this exact state before, no use searching further
		if callback_state_hash and states_already_visited.has(get_state_hash()):
			search_further = false
		
		# if not satisfied, recurse further
		if search_further:
			search_recursive(cur_depth + 1)
		
		# always undo whatever we did
		commands.undo_last_turn()
