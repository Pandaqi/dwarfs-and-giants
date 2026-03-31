class_name PuzzleSettings

static func get_difficulty() -> PuzzleDifficulty:
	return PuzzleFramework.difficulties[PuzzleFramework.current_difficulty]

static func get_difficulty_level() -> PuzzleDifficulty.Difficulty:
	return get_difficulty().difficulty

static func get_difficulty_string() -> String:
	return PuzzleDifficulty.Difficulty.keys()[get_difficulty_level()]

static func get_difficulty_property(key:String) -> Variant:
	var props := get_difficulty().properties
	if not (key in props): return null
	return props[key]

static func apply_difficulty_properties(obj) -> void:
	var diff := get_difficulty()
	for key in diff.properties:
		if not (key in obj): continue
		obj[key] = diff.properties[key]

static func has_settings() -> bool:
	return PuzzleFramework.settings.size() > 0

static func get_value(key:String) -> Variant:
	if not (key in PuzzleFramework.settings_by_id): return false
	return PuzzleFramework.settings_by_id[key].get_value_safe()
