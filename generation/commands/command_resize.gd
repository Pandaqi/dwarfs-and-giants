extends PuzzleCommand
class_name CommandResize

var cell : CellData
var size_change : int

func _init(c:CellData, ds:int):
	cell = c
	size_change = ds

func matches(cmd:PuzzleCommand) -> bool:
	if not (cmd is CommandResize): return false
	return cell == cmd.cell and size_change == cmd.size_change

func do(_cmds:PuzzleCommands) -> bool:
	cell.change_size(size_change)
	return true

func undo(_cmds:PuzzleCommands) -> bool:
	cell.change_size(-size_change)
	return true
