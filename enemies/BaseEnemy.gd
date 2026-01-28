class_name BaseEnemy
extends CharacterBody2D

const AttackType = preload("res://system/AttackType.gd")

@export var move_speed: float = 120.0
@export var melee_range: float = 40.0
@export var attack_range: float = 360.0
@export var attack_cooldown: float = 1.2
@export var is_ranged: bool = false
@export var attack_type: int = AttackType.Type.PHYSICAL
@export var projectile_scene: PackedScene

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var _cooldown: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	add_to_group("enemy")


func _physics_process(delta: float) -> void:
	_cooldown = maxf(0.0, _cooldown - delta)

	if not is_on_floor():
		velocity.y += gravity * delta

	var player: Player = _get_player()
	if player:
		var to_player: Vector2 = player.global_position - global_position
		var dir: float = signf(to_player.x)

		if is_ranged:
			velocity.x = 0.0
			if absf(to_player.x) <= attack_range and _cooldown <= 0.0:
				_shoot(dir)
		else:
			if absf(to_player.x) > melee_range:
				velocity.x = dir * move_speed
			else:
				velocity.x = 0.0
				if _cooldown <= 0.0:
					_melee_hit(player)

	move_and_slide()


func _shoot(dir: float) -> void:
	if not projectile_scene:
		return
	var projectile: Area2D = projectile_scene.instantiate()
	projectile.position = global_position + Vector2(dir * 24.0, -8.0)
	if projectile.has_method("set"):
		projectile.set("direction", Vector2(dir, 0.0))
		projectile.set("attack_type", attack_type)
	var parent_node = get_parent()
	if parent_node:
		parent_node.add_child(projectile)
	_cooldown = attack_cooldown
	print("[Enemy] shoot dir=", dir)


func _melee_hit(player: Player) -> void:
	var blocked: bool = player.is_blocking_for_attack(attack_type)
	if blocked:
		print("[Enemy] melee blocked")
	else:
		print("[Enemy] melee hit")
		player.request_respawn("melee")
	_cooldown = attack_cooldown


func _get_player() -> Player:
	var player_node = get_tree().get_first_node_in_group("player")
	return player_node as Player
