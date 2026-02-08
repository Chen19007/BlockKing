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

var _step: TutorialStep = TutorialStep.INTRO
var _physical_enemy: BaseEnemy = null
var _magic_enemy: BaseEnemy = null

@onready var physical_trigger: Area2D = $TriggerPhysical
@onready var magic_trigger: Area2D = $TriggerMagic
@onready var physical_spawn: Marker2D = $SpawnPhysical
@onready var magic_spawn: Marker2D = $SpawnMagic
@onready var transport: Area2D = $Transport


func _ready() -> void:
	super._ready()
	_bind_triggers()
	_set_transport_enabled(false)
	_show_dialogue("教学：A/D移动，空格跳跃，L攻击。先向右前进。")
	_step = TutorialStep.WAIT_PHYSICAL_TRIGGER


func _bind_triggers() -> void:
	if physical_trigger:
		physical_trigger.collision_layer = CollisionLayersClass.WORLD_PHYSICS
		physical_trigger.collision_mask = CollisionLayersClass.PLAYER_PHYSICS
	if (
		physical_trigger
		and not physical_trigger.body_entered.is_connected(_on_physical_trigger_body_entered)
	):
		physical_trigger.body_entered.connect(_on_physical_trigger_body_entered)
	if magic_trigger:
		magic_trigger.collision_layer = CollisionLayersClass.WORLD_PHYSICS
		magic_trigger.collision_mask = CollisionLayersClass.PLAYER_PHYSICS
	if magic_trigger and not magic_trigger.body_entered.is_connected(_on_magic_trigger_body_entered):
		magic_trigger.body_entered.connect(_on_magic_trigger_body_entered)


func _on_physical_trigger_body_entered(body: Node2D) -> void:
	if _step != TutorialStep.WAIT_PHYSICAL_TRIGGER:
		return
	if not body.is_in_group("player"):
		return
	_disable_trigger(physical_trigger)
	call_deferred("_spawn_physical_enemy")
	_show_dialogue("远程物理教学：按 J 进行物理格挡，挡住箭矢后用 L 击败敌人。")
	_step = TutorialStep.WAIT_PHYSICAL_DEFEAT


func _on_magic_trigger_body_entered(body: Node2D) -> void:
	if _step != TutorialStep.WAIT_MAGIC_TRIGGER:
		return
	if not body.is_in_group("player"):
		return
	_disable_trigger(magic_trigger)
	call_deferred("_spawn_magic_enemy")
	_show_dialogue("远程魔法教学：按 K 进行魔法格挡，挡住法术后用 L 击败敌人。")
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
	_show_dialogue("做得好，继续向右前进，学习魔法格挡。")
	_step = TutorialStep.WAIT_MAGIC_TRIGGER


func _on_magic_enemy_exited() -> void:
	_magic_enemy = null
	if _step != TutorialStep.WAIT_MAGIC_DEFEAT:
		return
	_show_dialogue("教学完成，你现在可以自由行动。前往右侧传送点进入第一关。")
	_set_transport_enabled(true)
	_step = TutorialStep.FREE


func _disable_trigger(trigger_area: Area2D) -> void:
	if not trigger_area:
		return
	trigger_area.set_deferred("monitoring", false)
	trigger_area.set_deferred("monitorable", false)


func _set_transport_enabled(enabled: bool) -> void:
	if not transport:
		return
	transport.set_deferred("monitoring", enabled)
	transport.set_deferred("monitorable", enabled)


func _show_dialogue(text: String) -> void:
	var main_node: Node = get_tree().get_first_node_in_group("main")
	if not main_node:
		return
	var dialogue_ui := main_node.get_node_or_null("DialogueUI") as DialogueUI
	if dialogue_ui:
		dialogue_ui.show_dialogue(text)
