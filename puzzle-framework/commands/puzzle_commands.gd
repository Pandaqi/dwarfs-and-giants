extends Node
class_name PuzzleCommands

## Contains all commands executed on every turn => Array[Array[PuzzleCommand]]
var history : Array = []

## True while it's busy doing/undoing commands (which allows you to check if you're able/allowed to make a new action happen or not)
var busy := false

## You can set this to true while generating because you might want certain things to not happen (rr happen differently) while generating compared to while playing
@export var generating := true

## Whether it plays a sound effect upon rewind => @TODO: will probably be extended to a more general "trigger (visual) effects or not" in the future
@export var play_audio := false

## Custom set by the game; the list of commands that represent the solution to the puzzle
var solution : Array[PuzzleCommand] = []

## Used for tracking where we are when solving solution in sequence;
## If we allow giving a hint at any moment, we need to manually track the turn number and set it here too
var solution_index := -1

signal do_started()
signal do_finished()
signal undo_started()
signal undo_finished()

func has_turns() -> bool:
	return count() > 0

func count() -> int:
	return history.size()

func is_busy() -> bool:
	return busy

func prepare_for_play() -> void:
	PuzzleFramework.commands = self
	play_audio = true
	generating = false

func get_current_turn() -> Array[PuzzleCommand]:
	var arr : Array[PuzzleCommand] = []
	if not has_turns(): return arr
	arr.assign(history.back())
	return arr

func register_command(cmd:PuzzleCommand) -> void:
	history.back().append(cmd)

func start_new_turn() -> void:
	history.append([])

func delete_last_turn() -> void:
	history.pop_back()

func execute_command(cmd:PuzzleCommand) -> void:
	busy = true
	do_started.emit()
	
	register_command(cmd)
	await cmd.do(self)
	
	do_finished.emit()
	busy = false

func undo_last_turn() -> void:
	if not has_turns(): return
	if is_busy(): return
	
	busy = true
	undo_started.emit()
	
	play_undo_audio()
	
	var commands : Array[PuzzleCommand] = get_current_turn()
	commands.reverse()
	
	for cmd in commands:
		await cmd.undo(self)
	
	delete_last_turn()
	
	undo_finished.emit()
	busy = false

func undo_all_turns() -> void:
	if is_busy(): return
	
	while has_turns():
		await undo_last_turn()

func set_solution(s:Array[PuzzleCommand]) -> void:
	solution = s
	solution_index = -1

func get_solution_for_turn(idx:int) -> PuzzleCommand:
	if idx < 0  or idx >= solution.size(): return null
	return solution[idx]

func get_solution_player_for_turn(idx:int) -> PuzzleCommand:
	if idx < 0  or idx >= count(): return null
	return history[idx][0]

func give_next_hint() -> void:
	if is_busy(): return
	
	# check until what index the player still did the right turns
	var last_matching_index := -1
	for i in range(count()):
		var cmd_sol := get_solution_for_turn(i)
		var cmd_player := get_solution_player_for_turn(i)
		if (not cmd_sol) or (not cmd_player): break
		if not cmd_player.matches(cmd_sol): break
		last_matching_index = i
	
	# go back to that state
	var current_turn := count() - 1
	for i in range(current_turn, last_matching_index, -1):
		await undo_last_turn()
	
	# now just take the next step from there
	solution_index = last_matching_index + 1
	if solution_index < 0 or solution_index >= solution.size(): return
	
	start_new_turn()
	await execute_command(get_solution_for_turn(solution_index))

func play_full_solution() -> void:
	solution_index = -1
	while solution_index < solution.size():
		await give_next_hint()

func play_undo_audio() -> void:
	if not play_audio: return
	PuzzleAudio.play_audio_nice(PuzzleFramework.audio.undo_audio)
