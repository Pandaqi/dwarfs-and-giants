extends Node
class_name PuzzleDebug

func _input(ev:InputEvent) -> void:
	if not OS.is_debug_build(): return
	debug_commands(ev)
	# debug_something_else()

func debug_commands(ev) -> void:
	if not PuzzleFramework.commands: return
	
	if ev.is_action_released("ui_accept"):
		PuzzleFramework.commands.undo_last_turn()
	if ev.is_action_released("ui_cancel"):
		PuzzleFramework.commands.play_full_solution()
