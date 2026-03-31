class_name PuzzleConnection

var a : PuzzleCell
var b : PuzzleCell

func _init(start:PuzzleCell, end:PuzzleCell):
	a = start
	b = end

func get_other(c:PuzzleCell) -> PuzzleCell:
	if a == c: return b
	return a
