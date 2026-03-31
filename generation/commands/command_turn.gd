extends PuzzleCommand
class_name CommandTurn

var cell : CellData
var type_removed : CellData.Type

func _init(c:CellData):
	cell = c

func matches(cmd:PuzzleCommand) -> bool:
	if not (cmd is CommandTurn): return false
	return cell == cmd.cell

func do(cmds:PuzzleCommands) -> bool:
	type_removed = cell.remove_type()
	
	var should_shrink_nbs : bool = (type_removed == CellData.Type.DWARF and PuzzleSettings.get_difficulty_property("dwarfs_shrink_neighbors"))
	var should_grow_nbs : bool = (type_removed == CellData.Type.GIANT and PuzzleSettings.get_difficulty_property("giants_grow_neighbors"))
	
	if should_shrink_nbs or should_grow_nbs:
		var ds := +1 if should_grow_nbs else -1
		for nb in cell.get_neighbors():
			if not nb.has_type(): continue
			cmds.execute_command(CommandResize.new(nb, ds))
	
	return true

func undo(_cmds:PuzzleCommands) -> bool:
	cell.set_type(type_removed)
	return true
