class_name BaseEnemy
extends CharacterBody2D

enum EnemyState { IDLE, WALK, ATTACK, HURT, DEAD }

const AttackTypeClass = preload("res://system/AttackType.gd")
const CollisionLayersClass = preload("res://system/CollisionLayers.gd")
const DifficultyManagerClass = preload("res://system/DifficultyManager.gd")

@export var move_speed: float = 120.0
@export var melee_range: float = 40.0
@export var attack_range: float = 360.0
@export var attack_cooldown: float = 1.2
@export var is_ranged: bool = false
@export var attack_type: int = AttackTypeClass.Type.PHYSICAL
@export var projectile_scene: PackedScene
@export var max_health: int = 1
@export var idle_animation_name: StringName = &"idle"
@export var walk_animation_name: StringName = &"walk"
@export var attack_animation_name: StringName = &"attack"
@export var hurt_animation_name: StringName = &"hurt"
@export var death_animation_name: StringName = &"death"
@export var hurt_recover_by_track_event: bool = false
@export var hurt_state_duration: float = 0.2
@export var death_despawn_delay: float = 0.25

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var _current_health: int = 1
var _enemy_state: EnemyState = EnemyState.IDLE
var _state_elapsed: float = 0.0
var _facing_dir: float = 1.0
var _melee_hit_box_origin: Vector2 = Vector2.ZERO
var _attack_cooldown_remaining: float = 0.0
var _effective_attack_cooldown: float = 1.2
var _story_paused: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var body_collision_shape: CollisionShape2D = (
	get_node_or_null("CollisionShape2D") as CollisionShape2D
)
@onready var melee_hit_box: HitBox = get_node_or_null("HitBox") as HitBox
@onready var melee_hit_shape: CollisionShape2D = (
	get_node_or_null("HitBox/CollisionShape2D") as CollisionShape2D
)
@onready var hurt_box: HurtBox = get_node_or_null("HurtBox") as HurtBox
@onready var detect_ray: RayCast2D = get_node_or_null("DetectRay") as RayCast2D
@onready var attack_ray: RayCast2D = get_node_or_null("AttackRay") as RayCast2D


func _ready() -> void:
	add_to_group("enemy")
	_current_health = max(1, max_health)
	_effective_attack_cooldown = DifficultyManagerClass.get_enemy_attack_cooldown(attack_cooldown)
	if melee_hit_box:
		melee_hit_box.attack_type = attack_type
		melee_hit_box.hit_reason = "melee"
		_set_melee_hitbox_enabled(false)
		_melee_hit_box_origin = melee_hit_box.position
	_apply_melee_hitbox_transform()
	if hurt_box and not hurt_box.hurt.is_connected(_on_hurt_box_hurt):
		hurt_box.hurt.connect(_on_hurt_box_hurt)
	if not animation_player:
		push_error("[Enemy] Missing AnimationPlayer on " + str(name))
		return
	if not animation_player.animation_finished.is_connected(_on_animation_finished):
		animation_player.animation_finished.connect(_on_animation_finished)
	if detect_ray:
		detect_ray.collision_mask = CollisionLayersClass.PLAYER_PHYSICS
	if attack_ray:
		attack_ray.collision_mask = CollisionLayersClass.PLAYER_PHYSICS
	_update_rays_direction()
	_transition_enemy_state(EnemyState.IDLE)


func _physics_process(delta: float) -> void:
	if _is_story_playing():
		if not _story_paused:
			_story_paused = true
			if animation_player:
				animation_player.speed_scale = 0.0
			anim_disable_melee_hitbox()
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if _story_paused:
		_story_paused = false
		if animation_player:
			animation_player.speed_scale = 1.0

	_update_state_timer(delta)
	_attack_cooldown_remaining = maxf(0.0, _attack_cooldown_remaining - delta)

	if not is_on_floor():
		velocity.y += gravity * delta

	if _enemy_state == EnemyState.DEAD:
		velocity.x = 0.0
		move_and_slide()
		return
	if _enemy_state == EnemyState.HURT:
		velocity.x = 0.0
		move_and_slide()
		return

	var player: Player = _get_player()
	if player:
		var to_player: Vector2 = player.global_position - global_position
		var dir: float = signf(to_player.x)
		if absf(to_player.x) > 0.01:
			_update_sprite_facing(dir)
		_update_rays_direction()

		var detected: bool = _ray_hits_player(detect_ray, player)
		if detected:
			var in_attack_range: bool = _ray_hits_player(attack_ray, player)
			if in_attack_range:
				velocity.x = 0.0
				_start_attack(dir)
			else:
				velocity.x = dir * move_speed
		else:
			velocity.x = 0.0
	else:
		velocity.x = 0.0

	_update_state_machine()
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
	print("[Enemy] shoot dir=", dir)


func _melee_hit(player: Player) -> void:
	if melee_hit_box:
		var has_hurt_target: bool = false
		var areas: Array[Area2D] = melee_hit_box.get_overlapping_areas()
		for area in areas:
			var target_hurt_box := area as HurtBox
			if not target_hurt_box:
				continue
			has_hurt_target = true
			var hit_source_direction: Vector2 = (
				melee_hit_box.global_position - target_hurt_box.global_position
			)
			if hit_source_direction.length_squared() > 0.0001:
				hit_source_direction = hit_source_direction.normalized()
			else:
				hit_source_direction = Vector2.ZERO
			target_hurt_box.take_hit(melee_hit_box, hit_source_direction)
			print("[Enemy] melee hitbox hit")
			break
		if not has_hurt_target:
			print("[Enemy] melee miss")
		return

	var source_direction: Vector2 = global_position - player.global_position
	if source_direction.length_squared() > 0.0001:
		source_direction = source_direction.normalized()
	else:
		source_direction = Vector2.ZERO
	var blocked: bool = player.can_block_attack_from(attack_type, source_direction)
	if blocked:
		print("[Enemy] melee blocked")
	else:
		print("[Enemy] melee hit")
		player.request_respawn("melee")


func _get_player() -> Player:
	var player_node = get_tree().get_first_node_in_group("player")
	return player_node as Player


func _on_hurt_box_hurt(_from: HitBox, _source_direction: Vector2) -> void:
	_apply_damage(1)


func _apply_damage(amount: int) -> void:
	if _enemy_state == EnemyState.DEAD:
		return
	_current_health = maxi(0, _current_health - amount)
	print("[Enemy] hurt hp=", _current_health, "/", max_health)
	if _current_health <= 0:
		print("[Enemy] defeated")
		_transition_enemy_state(EnemyState.DEAD)
		return
	_transition_enemy_state(EnemyState.HURT)


func _update_sprite_facing(dir: float) -> void:
	if not sprite:
		return
	if dir < 0.0:
		sprite.flip_h = true
		_facing_dir = -1.0
	elif dir > 0.0:
		sprite.flip_h = false
		_facing_dir = 1.0
	_apply_melee_hitbox_transform()


func get_attack_direction() -> Vector2:
	if sprite and sprite.flip_h:
		return Vector2.LEFT
	return Vector2.RIGHT


func _update_state_machine() -> void:
	if _enemy_state == EnemyState.ATTACK:
		return
	if _enemy_state == EnemyState.HURT:
		return
	if _enemy_state == EnemyState.DEAD:
		return
	if absf(velocity.x) > 0.01:
		_transition_enemy_state(EnemyState.WALK)
		return
	_transition_enemy_state(EnemyState.IDLE)


func _start_attack(_attack_dir: float) -> void:
	_start_attack_animation()
	if _enemy_state != EnemyState.ATTACK:
		return


func _start_attack_animation() -> void:
	if _enemy_state == EnemyState.DEAD or _enemy_state == EnemyState.HURT:
		return
	if _attack_cooldown_remaining > 0.0:
		return
	if not _has_animation(attack_animation_name):
		return
	_attack_cooldown_remaining = _effective_attack_cooldown
	_transition_enemy_state(EnemyState.ATTACK)


func _transition_enemy_state(next_state: EnemyState) -> void:
	if _enemy_state == next_state:
		return
	_enemy_state = next_state
	_state_elapsed = 0.0
	_on_enter_state(next_state)
	_play_animation(_state_to_animation(next_state))


func _state_to_animation(state: EnemyState) -> StringName:
	match state:
		EnemyState.ATTACK:
			return attack_animation_name
		EnemyState.HURT:
			return hurt_animation_name
		EnemyState.DEAD:
			return death_animation_name
		EnemyState.WALK:
			return walk_animation_name
		_:
			return idle_animation_name


func _has_animation(animation_name: StringName) -> bool:
	return animation_player and animation_player.has_animation(animation_name)


func _play_animation(animation_name: StringName) -> void:
	if not _has_animation(animation_name):
		push_warning("[Enemy] Missing animation: " + String(animation_name) + " on " + str(name))
		return
	animation_player.play(animation_name)


func _on_animation_finished(animation_name: StringName) -> void:
	if animation_name == attack_animation_name:
		_on_attack_animation_finished()
		return
	if animation_name == hurt_animation_name:
		if hurt_recover_by_track_event:
			return
		_on_hurt_animation_finished()
		return
	if animation_name == death_animation_name:
		_on_death_animation_finished()


func _on_attack_animation_finished() -> void:
	if _enemy_state != EnemyState.ATTACK:
		return
	anim_disable_melee_hitbox()
	if absf(velocity.x) > 0.01:
		_transition_enemy_state(EnemyState.WALK)
		return
	_transition_enemy_state(EnemyState.IDLE)


func _on_hurt_animation_finished() -> void:
	if _enemy_state != EnemyState.HURT:
		return
	if absf(velocity.x) > 0.01:
		_transition_enemy_state(EnemyState.WALK)
		return
	_transition_enemy_state(EnemyState.IDLE)


func _on_death_animation_finished() -> void:
	if _enemy_state != EnemyState.DEAD:
		return
	queue_free()


func _on_enter_state(state: EnemyState) -> void:
	if state == EnemyState.IDLE or state == EnemyState.WALK or state == EnemyState.HURT:
		anim_disable_melee_hitbox()
		return
	if state == EnemyState.DEAD:
		if melee_hit_box:
			_set_melee_hitbox_enabled(false)
		if body_collision_shape:
			body_collision_shape.set_deferred("disabled", true)


func _update_state_timer(delta: float) -> void:
	if _enemy_state == EnemyState.HURT and not hurt_recover_by_track_event:
		_state_elapsed += delta
		if _state_elapsed >= hurt_state_duration:
			_on_hurt_animation_finished()
		return
	if _enemy_state == EnemyState.DEAD and not _has_animation(death_animation_name):
		_state_elapsed += delta
		if _state_elapsed >= death_despawn_delay:
			_on_death_animation_finished()


func anim_enable_melee_hitbox() -> void:
	_set_melee_hitbox_enabled(true)


func anim_disable_melee_hitbox() -> void:
	_set_melee_hitbox_enabled(false)


func anim_commit_attack() -> void:
	_commit_attack()


func _commit_pending_attack() -> void:
	_commit_attack()


func _commit_attack() -> void:
	if is_ranged:
		_shoot(_facing_dir)
		return
	anim_enable_melee_hitbox()
	var player: Player = _get_player()
	if player:
		_melee_hit(player)


func anim_end_hurt_state() -> void:
	_on_hurt_animation_finished()


func _apply_melee_hitbox_transform() -> void:
	if not melee_hit_box:
		return
	melee_hit_box.position = Vector2(_melee_hit_box_origin.x * _facing_dir, _melee_hit_box_origin.y)


func _set_melee_hitbox_enabled(enabled: bool) -> void:
	if not melee_hit_shape:
		return
	melee_hit_shape.set_deferred("disabled", not enabled)


func _update_rays_direction() -> void:
	if detect_ray:
		detect_ray.target_position.x = absf(detect_ray.target_position.x) * _facing_dir
	if attack_ray:
		attack_ray.target_position.x = absf(attack_ray.target_position.x) * _facing_dir


func _ray_hits_player(ray: RayCast2D, player: Player) -> bool:
	if not ray or not player:
		return false
	ray.force_raycast_update()
	if not ray.is_colliding():
		return false
	var collider: Object = ray.get_collider()
	if collider == player:
		return true
	var collider_node := collider as Node
	return collider_node and collider_node.owner == player


func _is_story_playing() -> bool:
	var runner: Node = get_node_or_null("/root/StoryEventRunner")
	if not runner:
		return false
	if not runner.has_method("is_story_playing"):
		return false
	return bool(runner.call("is_story_playing"))
