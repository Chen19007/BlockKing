extends Node

enum Difficulty { TUTORIAL, EASY, NORMAL, HARD }

const DIFFICULTY_NAMES: Dictionary = {
	Difficulty.TUTORIAL: "教学",
	Difficulty.EASY: "简单",
	Difficulty.NORMAL: "普通",
	Difficulty.HARD: "困难"
}

const DIFFICULTY_CONFIGS: Dictionary = {
	Difficulty.TUTORIAL:
	{
		"enemy_attack_cooldown_scale": 1.8
	},
	Difficulty.EASY:
	{
		"enemy_attack_cooldown_scale": 1.3
	},
	Difficulty.NORMAL:
	{
		"enemy_attack_cooldown_scale": 1.0
	},
	Difficulty.HARD:
	{
		"enemy_attack_cooldown_scale": 0.8
	}
}

const TUTORIAL_SECTION_IDS: PackedStringArray = [&"section0_tutorial"]

static var _selected_game_difficulty: Difficulty = Difficulty.NORMAL
static var _current_difficulty: Difficulty = Difficulty.NORMAL


static func set_game_difficulty(difficulty: Difficulty) -> void:
	_selected_game_difficulty = difficulty
	_current_difficulty = difficulty


static func get_game_difficulty() -> Difficulty:
	return _selected_game_difficulty


static func get_current_difficulty() -> Difficulty:
	return _current_difficulty


static func get_current_difficulty_name() -> String:
	return DIFFICULTY_NAMES.get(_current_difficulty, "未知")


static func apply_section_preset(section_id: String) -> void:
	if TUTORIAL_SECTION_IDS.has(StringName(section_id)):
		_current_difficulty = Difficulty.TUTORIAL
		return
	_current_difficulty = _selected_game_difficulty


static func get_enemy_attack_cooldown(base_cooldown: float) -> float:
	var config: Dictionary = DIFFICULTY_CONFIGS.get(_current_difficulty, {})
	var scale: float = float(config.get("enemy_attack_cooldown_scale", 1.0))
	return maxf(0.1, base_cooldown * scale)
