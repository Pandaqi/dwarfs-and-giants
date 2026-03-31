extends Node
class_name PuzzleFrameworkAutoload

@export_group("Game Core")
@export var game_name := "GameName"
@export var game_version := "1.0"
@export var game_tagline := "Educational Puzzle Game"
@export var creator_credit := "The Wayward Melody"
@export var favicon := ""

@export_group("Menu")
@export var menu_pattern_enabled := false
@export var menu_scene_custom : PackedScene
@export var menu_background_color := Color(0, 135/255.0, 244/255.0)
@export var menu_pattern_color := Color(87/255.0, 167/255.0, 1.0)

@export_group("Difficulties & Campaign")
var current_difficulty := 0
@export var difficulties : Array[PuzzleDifficulty] = []
var difficulties_by_id : Dictionary[PuzzleDifficulty.Difficulty, PuzzleDifficulty] = {}

@export_group("Settings & Configuration")
@export var settings : Array[PuzzleSetting] = []
var settings_by_id : Dictionary[String, PuzzleSetting] = {}

@export_group("Theme & Interface")
@export var default_theme : Theme = preload("res://puzzle-framework/ui/puzzle_theme_default.tres")
@export var font_heading : FontFile = preload("res://puzzle-framework/ui/fonts/LilitaOne-Regular.ttf")
@export var font_body : FontFile = preload("res://puzzle-framework/ui/fonts/LilitaOne-Regular.ttf")

@export_group("Audio")
@export var bg_music : Array[AudioStream] = []

var commands : PuzzleCommands

var puzzle_seed := 0
var state := State.MENU
var audio : PuzzleAudio
var debug : PuzzleDebug

var num_attempts := 0
var num_attempts_same_puzzle := 1
var num_attempts_per_difficulty : Dictionary[PuzzleDifficulty.Difficulty, int] = {}

enum State
{
	MENU,
	LOAD,
	PUZZLE,
	DONE
}

signal puzzle_started()
signal puzzle_reopened()
signal puzzle_done(player_won:bool)

func _enter_tree() -> void:
	audio = PuzzleAudio.new()
	add_child(audio)
	
	debug = PuzzleDebug.new()
	add_child(debug)
	
	for setting in settings:
		settings_by_id[setting.key] = setting
	
	for difficulty in difficulties:
		difficulties_by_id[difficulty.difficulty] = difficulty

func _ready() -> void:
	default_theme.default_font = font_body
	ProjectSettings.set_setting("gui/theme/custom", default_theme)
	
	audio.load_background_music(bg_music)

func go_back_to_menu() -> void:
	change_state(State.MENU)
	get_tree().change_scene_to_file("res://puzzle-framework/menu/menu.tscn")

func prepare_attempt(retry := false) -> void:
	seed(puzzle_seed)
	num_attempts += 1
	if retry: num_attempts_same_puzzle += 1
	else: num_attempts_same_puzzle = 1
	
	if not (current_difficulty in num_attempts_per_difficulty): num_attempts_per_difficulty[current_difficulty] = 0
	num_attempts_per_difficulty[current_difficulty] += 1

func reload_current_puzzle() -> void:
	prepare_attempt(true)
	change_state(State.LOAD)
	get_tree().reload_current_scene()

func load_new_puzzle(diff := PuzzleSettings.get_difficulty_level()) -> void:
	current_difficulty = difficulties.find(difficulties_by_id[diff])
	puzzle_seed = randi()
	prepare_attempt()
	change_state(State.LOAD)
	get_tree().change_scene_to_file("res://main/main.tscn")

func start_puzzle() -> void:
	change_state(State.PUZZLE)
	audio.state_audio.play()
	puzzle_started.emit()

func reopen_puzzle() -> void:
	change_state(State.PUZZLE)
	commands.undo_last_turn()
	puzzle_reopened.emit()

func finish_puzzle(player_won := false) -> void:
	change_state(State.DONE)
	puzzle_done.emit(player_won)

func change_state(s:State) -> void:
	state = s

func get_num_attempts_current_difficulty() -> int:
	if not (current_difficulty in num_attempts_per_difficulty): return 0
	return num_attempts_per_difficulty[current_difficulty]
