extends "res://stages/stage1/Section.gd"

enum TutorialStep {
	INTRO,
	WAIT_PHYSICAL_TRIGGER,
	WAIT_PHYSICAL_DEFEAT,
	WAIT_MAGIC_TRIGGER,
	WAIT_MAGIC_DEFEAT,
	FREE
}

const SkeletonArcherScene = preload("res://enemies/SkeletonArcher.tscn")
const PriestScene = preload("res://enemies/Priest.tscn")
const CollisionLayersClass = preload("res://system/CollisionLayers.gd")
const StoryDataClass = preload("res://system/StoryData.gd")

var _step: TutorialStep = TutorialStep.INTRO
var _physical_enemy: BaseEnemy = null
var _magic_enemy: BaseEnemy = null
var _dialogues: Dictionary = {}

@onready var physical_trigger: StoryTrigger = $TriggerPhysical
@onready var magic_trigger: StoryTrigger = $TriggerMagic
@onready var physical_spawn: Marker2D = $SpawnPhysical
@onready var magic_spawn: Marker2D = $SpawnMagic
@onready var transport: Area2D = $Transport


func _ready() -> void:
	super._ready()
	_load_story_data()
	_bind_triggers()
	_set_transport_enabled(false)
	_play_dialogue(_get_story_lines(&"intro"))
	_step = TutorialStep.WAIT_PHYSICAL_TRIGGER


func _bind_triggers() -> void:
	_apply_trigger_dialogues()
	if physical_trigger:
		physical_trigger.collision_layer = CollisionLayersClass.WORLD_PHYSICS
		physical_trigger.collision_mask = CollisionLayersClass.PLAYER_PHYSICS
	if physical_trigger and not physical_trigger.triggered.is_connected(_on_physical_triggered):
		physical_trigger.triggered.connect(_on_physical_triggered)
	if magic_trigger:
		magic_trigger.collision_layer = CollisionLayersClass.WORLD_PHYSICS
		magic_trigger.collision_mask = CollisionLayersClass.PLAYER_PHYSICS
	if magic_trigger and not magic_trigger.triggered.is_connected(_on_magic_triggered):
		magic_trigger.triggered.connect(_on_magic_triggered)

func _on_physical_triggered(_trigger_id: StringName) -> void:
	if _step != TutorialStep.WAIT_PHYSICAL_TRIGGER:
		return
	call_deferred("_spawn_physical_enemy")
	_step = TutorialStep.WAIT_PHYSICAL_DEFEAT


func _on_magic_triggered(_trigger_id: StringName) -> void:
	if _step != TutorialStep.WAIT_MAGIC_TRIGGER:
		return
	call_deferred("_spawn_magic_enemy")
	_step = TutorialStep.WAIT_MAGIC_DEFEAT


func _spawn_physical_enemy() -> void:
	var enemy: BaseEnemy = SkeletonArcherScene.instantiate() as BaseEnemy
	if enemy == null:
		return
	enemy.position = physical_spawn.position
	enemy.move_speed = 0.0
	add_child(enemy)
	_physical_enemy = enemy
	if not enemy.tree_exited.is_connected(_on_physical_enemy_exited):
		enemy.tree_exited.connect(_on_physical_enemy_exited)


func _spawn_magic_enemy() -> void:
	var enemy: BaseEnemy = PriestScene.instantiate() as BaseEnemy
	if enemy == null:
		return
	enemy.position = magic_spawn.position
	enemy.move_speed = 0.0
	add_child(enemy)
	_magic_enemy = enemy
	if not enemy.tree_exited.is_connected(_on_magic_enemy_exited):
		enemy.tree_exited.connect(_on_magic_enemy_exited)


func _on_physical_enemy_exited() -> void:
	_physical_enemy = null
	if _step != TutorialStep.WAIT_PHYSICAL_DEFEAT:
		return
	_play_dialogue(_get_story_lines(&"after_physical"))
	_step = TutorialStep.WAIT_MAGIC_TRIGGER


func _on_magic_enemy_exited() -> void:
	_magic_enemy = null
	if _step != TutorialStep.WAIT_MAGIC_DEFEAT:
		return
	_play_dialogue(_get_story_lines(&"after_magic"))
	_set_transport_enabled(true)
	_step = TutorialStep.FREE


func _set_transport_enabled(enabled: bool) -> void:
	if not transport:
		return
	transport.set_deferred("monitoring", enabled)
	transport.set_deferred("monitorable", enabled)


func _play_dialogue(lines: Array[String]) -> void:
	var runner := get_node("/root/StoryEventRunner") as StoryEventRunner
	runner.play_dialogues(lines, true)


func _load_story_data() -> void:
	_dialogues = StoryDataClass.get_dialogues(section_id)


func _apply_trigger_dialogues() -> void:
	if physical_trigger:
		physical_trigger.dialogue_lines = _get_story_lines(
			&"trigger_physical", physical_trigger.dialogue_lines
		)
	if magic_trigger:
		magic_trigger.dialogue_lines = _get_story_lines(&"trigger_magic", magic_trigger.dialogue_lines)


func _get_story_lines(key: StringName, fallback: Array[String] = []) -> Array[String]:
	var raw_lines: Variant = _dialogues.get(String(key), fallback)
	var lines: Array[String] = []
	if raw_lines is Array:
		for line_variant in raw_lines:
			lines.append(str(line_variant))
	if lines.is_empty():
		return fallback
	return lines
