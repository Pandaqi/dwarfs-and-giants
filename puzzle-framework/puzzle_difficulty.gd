extends Resource
class_name PuzzleDifficulty

enum Difficulty
{
	EASIEST,
	EASY,
	MEDIUM,
	HARD,
	HARDEST
}

var difficulty_to_emoji : Dictionary[Difficulty, String] = {
	Difficulty.EASIEST: "yawn.png",
	Difficulty.EASY: "beaming-smile.png",
	Difficulty.MEDIUM: "raised-eyebrow.png",
	Difficulty.HARD: "anxious-sweat.png",
	Difficulty.HARDEST: "exploding-head.png",
}

var difficulty_to_label : Dictionary[Difficulty, String] = {
	Difficulty.EASIEST: "Difficulty: Easiest",
	Difficulty.EASY: "Difficulty: Easy",
	Difficulty.MEDIUM: "Difficulty: Medium",
	Difficulty.HARD: "Difficulty: Hard",
	Difficulty.HARDEST: "Difficulty: Hardest",
}

@export var difficulty := Difficulty.EASIEST
@export var button_label : String
@export var button_icon : Texture2D
@export var feedback : String = ""
@export var tutorial : Array[PuzzleTutorialStage] = []
@export var properties : Dictionary[String, Variant] = {}

func get_button_label() -> String:
	if button_label: return button_label
	return difficulty_to_label[difficulty]

func get_button_icon() -> Texture2D:
	if button_icon: return button_icon
	return load("res://puzzle-framework/ui/emojis/" + difficulty_to_emoji[difficulty])
