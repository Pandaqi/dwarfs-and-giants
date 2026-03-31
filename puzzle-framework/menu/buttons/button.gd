extends Button
class_name PuzzleMenuButton

func sync_difficulty(d:PuzzleDifficulty) -> void:
	text = d.get_button_label()
	icon = d.get_button_icon()
