@abstract class_name PuzzleCommand

@abstract func do(cmds:PuzzleCommands) -> bool
@abstract func undo(cmds:PuzzleCommands) -> bool
@abstract func matches(cmd:PuzzleCommand) -> bool
