class_name Player
extends CharacterBody2D

signal respawn_requested

enum PlayerState { IDLE, WALK, JUMP, FALL, BLOCK_PHYSICAL, BLOCK_MAGIC, ATTACK, HURT, DEAD }

const AttackTypeClass = preload("res://system/AttackType.gd")
const GameFlowConfigClass = preload("res://system/GameFlowConfig.gd")
const ProjectileScene = preload("res://enemies/Projectile.tscn")
const BlockImpactVfxScene = preload("res://vfx/BlockImpactVfx.tscn")
const BLOCK_VFX_OFFSET: float = 24.0
const PHYSICAL_BLOCK_VFX: StringName = &"block_physical_spark"
const MAGIC_BLOCK_VFX: StringName = &"block_magic_shield"

@export var move_speed: float = 240.0
@export var jump_velocity: float = -520.0
@export var debug_log_input: bool = true
@export var debug_log_state: bool = true
@export var fall_respawn_y: float = 900.0
@export var e2e_debug_enabled: bool = true
@export var e2e_step_distance: float = 200.0
@export var e2e_move_distance: float = 200.0
@export var e2e_move_speed: float = 220.0
@export var e2e_projectile_offset: Vector2 = Vector2(240.0, -8.0)
@export var e2e_projectile_speed: float = 360.0
@export var camera_horizon_offset_y: float = -220.0
@export var idle_animation_name: StringName = &"idle"
@export var walk_animation_name: StringName = &"walk"
@export var jump_animation_name: StringName = &"jump"
@export var fall_animation_name: StringName = &"fall"
@export var block_animation_name: StringName = &"block"
@export var attack_animation_name: StringName = &"attack"
@export var hurt_animation_name: StringName = &"hurt"
@export var death_animation_name: StringName = &"death"

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

var is_blocking_physical: bool = false
var is_blocking_magic: bool = false

var _story_input_locked: bool = false
var _respawn_queued: bool = false
var _e2e_move_remaining: float = 0.0
var _debug_force_block_physical: int = -1
var _debug_force_block_magic: int = -1
var _facing_dir: float = 1.0
var _attack_hit_box_origin: Vector2 = Vector2.ZERO
var _was_on_floor: bool = false

var _player_state: PlayerState = PlayerState.IDLE
var _current_visual_animation: StringName = &""

var _last_logged_position: Vector2 = Vector2.ZERO
var _last_input_dir: float = 0.0
var _last_blocking_physical: bool = false
var _last_blocking_magic: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hurt_box: HurtBox = $HurtBox
@onready var attack_hit_box: HitBox = $HitBox
@onready var attack_hit_shape: CollisionShape2D = $HitBox/CollisionShape2D
@onready var camera: Camera2D = $Camera2D
@onready var procedural_sfx: Node = (
	get_node_or_null("/root/ProceduralSFXService") as Node
)


func _ready() -> void:
	add_to_group("player")
	if hurt_box and not hurt_box.hurt.is_connected(_on_hurt_box_hurt):
		hurt_box.hurt.connect(_on_hurt_box_hurt)
	if attack_hit_box:
		attack_hit_box.attack_type = AttackTypeClass.Type.PHYSICAL
		attack_hit_box.hit_reason = "player_attack"
		_attack_hit_box_origin = attack_hit_box.position
	if attack_hit_shape:
		attack_hit_shape.disabled = true
	_apply_camera_horizon()
	_apply_attack_hitbox_transform()
	if (
		animation_player
		and not animation_player.animation_finished.is_connected(_on_animation_finished)
	):
		animation_player.animation_finished.connect(_on_animation_finished)
		animation_player.play(&"RESET")
		animation_player.advance(0.0)
	_play_animation(idle_animation_name)
	NodeReadyManager.notify_node_ready("Player", self)
	_last_logged_position = global_position
	_was_on_floor = is_on_floor()


func _physics_process(delta: float) -> void:
	if _player_state == PlayerState.DEAD:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	_update_block_state()

	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		if _can_accept_action_input() and Input.is_action_just_pressed("jump"):
			velocity.y = jump_velocity
			_play_jump_sfx()

	if _can_accept_action_input() and Input.is_action_just_pressed("attack"):
		_start_attack()

	var input_dir = Input.get_axis("move_left", "move_right")
	if absf(input_dir) > 0.0:
		_facing_dir = signf(input_dir)
		if sprite:
			sprite.flip_h = _facing_dir < 0.0
	_apply_attack_hitbox_transform()
	if absf(_e2e_move_remaining) > 0.0:
		var step = e2e_move_speed * delta
		var dir = signf(_e2e_move_remaining)
		var applied = minf(absf(_e2e_move_remaining), step) * dir
		_e2e_move_remaining -= applied
		velocity.x = applied / maxf(delta, 0.0001)
		if absf(_e2e_move_remaining) <= 0.01:
			_e2e_move_remaining = 0.0
	else:
		if not _can_accept_action_input() or _is_ground_blocking_locked():
			velocity.x = 0.0
		else:
			velocity.x = input_dir * move_speed

	_update_state_machine(input_dir)

	move_and_slide()
	_play_land_sfx_if_needed()

	#if global_position.y > fall_respawn_y:
	#request_respawn("fall")

	if debug_log_state:
		if input_dir != _last_input_dir:
			print("[Input] move_dir=", input_dir)
			_last_input_dir = input_dir
		if global_position.distance_to(_last_logged_position) >= 5.0:
			print("[State] player_pos=", global_position)
			_last_logged_position = global_position


func _input(event: InputEvent) -> void:
	if _handle_e2e_shortcuts(event):
		return

	if not debug_log_input:
		return

	if event.is_action_pressed("move_left"):
		print("[Input] move_left pressed")
	elif event.is_action_released("move_left"):
		print("[Input] move_left released")

	if event.is_action_pressed("move_right"):
		print("[Input] move_right pressed")
	elif event.is_action_released("move_right"):
		print("[Input] move_right released")

	if event.is_action_pressed("jump"):
		print("[Input] jump pressed")

	if event.is_action_pressed("attack"):
		print("[Input] attack pressed")

	if event.is_action_pressed("block_physical"):
		print("[Input] block_physical pressed")
	elif event.is_action_released("block_physical"):
		print("[Input] block_physical released")

	if event.is_action_pressed("block_magic"):
		print("[Input] block_magic pressed")
	elif event.is_action_released("block_magic"):
		print("[Input] block_magic released")


func _handle_e2e_shortcuts(event: InputEvent) -> bool:
	if not e2e_debug_enabled:
		return false
	if not event is InputEventKey:
		return false
	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.is_echo():
		return false
	if not (key_event.ctrl_pressed and key_event.alt_pressed and key_event.shift_pressed):
		return false

	match key_event.keycode:
		KEY_F1:
			_toggle_debug_block_physical()
		KEY_F2:
			_toggle_debug_block_magic()
		KEY_F3:
			_clear_debug_block_overrides()
		KEY_F5:
			_spawn_test_projectile(AttackTypeClass.Type.PHYSICAL)
		KEY_F6:
			_spawn_test_projectile(AttackTypeClass.Type.MAGIC)
		KEY_PAGEUP:
			_e2e_switch_section(true)
		KEY_PAGEDOWN:
			_e2e_switch_section(false)
		KEY_HOME:
			_e2e_load_section("section0_1")
		KEY_END:
			_e2e_load_section("section0_2")
		KEY_1:
			_teleport_to_debug_marker("DebugMarkerA")
		KEY_2:
			_teleport_to_debug_marker("DebugMarkerB")
		KEY_3:
			_set_debug_marker("DebugMarkerA")
		KEY_4:
			_set_debug_marker("DebugMarkerB")
		KEY_F7:
			_start_e2e_move(-e2e_move_distance)
		KEY_F8:
			_start_e2e_move(e2e_move_distance)
		KEY_F9:
			_apply_e2e_step(Vector2(e2e_step_distance, 0.0))
		KEY_F10:
			_apply_e2e_step(Vector2(-e2e_step_distance, 0.0))
		KEY_UP:
			_apply_e2e_step(Vector2(0.0, -e2e_step_distance))
		KEY_DOWN:
			_apply_e2e_step(Vector2(0.0, e2e_step_distance))
		KEY_F11:
			_teleport_to_respawn()

	get_viewport().set_input_as_handled()
	return true


func _spawn_test_projectile(attack_type: int) -> void:
	var projectile: Area2D = ProjectileScene.instantiate()
	if not projectile:
		print("[E2E] spawn_projectile failed")
		return

	var spawn_side: float = 1.0
	projectile.position = (
		global_position + Vector2(spawn_side * e2e_projectile_offset.x, e2e_projectile_offset.y)
	)
	if projectile.has_method("set"):
		projectile.set("direction", Vector2(-spawn_side, 0.0))
		projectile.set("attack_type", attack_type)
		projectile.set("speed", e2e_projectile_speed)

	var parent_node = get_parent()
	if parent_node:
		parent_node.add_child(projectile)
	else:
		add_child(projectile)

	print("[E2E] spawn_projectile type=", attack_type, " pos=", projectile.position)


func _e2e_switch_section(next: bool) -> void:
	var main_node = get_tree().get_first_node_in_group("main")
	if not main_node:
		print("[E2E] switch_section skipped (no Main)")
		return

	var current_id := ""
	if main_node.has_method("get_current_section_id"):
		current_id = main_node.get_current_section_id()
	else:
		current_id = str(main_node.get("current_section_id"))

	var target_id := ""
	if next:
		target_id = GameFlowConfigClass.get_next_section_id(current_id)
	else:
		var first_stage = GameFlowConfigClass.get_first_stage_id()
		target_id = GameFlowConfigClass.get_first_section_id(first_stage)

	if not main_node.has_method("switch_section"):
		print("[E2E] switch_section skipped (Main missing switch_section)")
		return

	main_node.call_deferred("switch_section", target_id)
	print("[E2E] switch_section target=", target_id)


func _e2e_load_section(section_id: String) -> void:
	var main_node = get_tree().get_first_node_in_group("main")
	if not main_node:
		print("[E2E] load_section skipped (no Main)")
		return
	if not main_node.has_method("load_section"):
		print("[E2E] load_section skipped (Main missing load_section)")
		return

	main_node.call_deferred("load_section", section_id)
	print("[E2E] load_section target=", section_id)


func _apply_e2e_step(delta: Vector2) -> void:
	global_position += delta
	velocity = Vector2.ZERO
	print("[E2E] step_move delta=", delta, " pos=", global_position)


func _start_e2e_move(distance: float) -> void:
	_e2e_move_remaining = distance
	velocity = Vector2.ZERO
	print("[E2E] smooth_move distance=", distance)


func _toggle_debug_block_physical() -> void:
	if _debug_force_block_physical == 1:
		_debug_force_block_physical = -1
	else:
		_debug_force_block_physical = 1
	print("[E2E] force_block_physical=", _debug_force_block_physical)


func _toggle_debug_block_magic() -> void:
	if _debug_force_block_magic == 1:
		_debug_force_block_magic = -1
	else:
		_debug_force_block_magic = 1
	print("[E2E] force_block_magic=", _debug_force_block_magic)


func _clear_debug_block_overrides() -> void:
	_debug_force_block_physical = -1
	_debug_force_block_magic = -1
	print("[E2E] clear_block_overrides")


func _set_debug_marker(marker_name: String) -> void:
	var marker = _get_debug_marker(marker_name)
	if marker:
		marker.position = position
		print("[E2E] set_marker ", marker_name, " pos=", marker.position)
	else:
		print("[E2E] set_marker skipped (missing ", marker_name, ")")


func _teleport_to_debug_marker(marker_name: String) -> void:
	var marker = _get_debug_marker(marker_name)
	if marker:
		position = marker.position
		velocity = Vector2.ZERO
		print("[E2E] teleport_marker ", marker_name, " pos=", position)
	else:
		print("[E2E] teleport_marker skipped (missing ", marker_name, ")")


func _get_debug_marker(marker_name: String) -> Node2D:
	var section = get_parent()
	if section:
		return section.get_node_or_null(marker_name) as Node2D
	return null


func _teleport_to_respawn() -> void:
	var section = get_parent()
	if section and section.has_method("get_respawn_point"):
		position = section.get_respawn_point()
		velocity = Vector2.ZERO
		print("[E2E] teleport_to_respawn pos=", position)
	else:
		print("[E2E] teleport_to_respawn skipped (no Section)")


func is_blocking_for_attack(attack_type: int) -> bool:
	if attack_type == AttackTypeClass.Type.PHYSICAL:
		return is_blocking_physical
	if attack_type == AttackTypeClass.Type.MAGIC:
		return is_blocking_magic
	return false


func can_block_attack_from(attack_type: int, source_direction: Vector2) -> bool:
	return is_blocking_for_attack(attack_type) and _is_front_attack(source_direction)


func get_attack_direction() -> Vector2:
	return Vector2(_facing_dir, 0.0)


func set_camera_limits(limits: Dictionary) -> void:
	if not camera:
		return
	if not limits.get("enabled", false):
		camera.limit_left = -10000000
		camera.limit_right = 10000000
		camera.limit_top = -10000000
		camera.limit_bottom = 10000000
		return
	camera.limit_left = int(limits.get("left", -10000000))
	camera.limit_right = int(limits.get("right", 10000000))
	camera.limit_top = int(limits.get("top", -10000000))
	camera.limit_bottom = int(limits.get("bottom", 10000000))


func request_respawn(reason: String = "") -> void:
	if _respawn_queued:
		return
	_transition_player_state(PlayerState.DEAD)
	_respawn_queued = true
	print("[State] respawn requested reason=", reason)
	respawn_requested.emit()


func _on_hurt_box_hurt(from: HitBox, source_direction: Vector2) -> void:
	var attack_type_value: int = AttackTypeClass.Type.PHYSICAL
	var hit_reason: String = "melee"
	if from:
		attack_type_value = from.attack_type
		if from.hit_reason != "":
			hit_reason = from.hit_reason
	var blocked: bool = can_block_attack_from(attack_type_value, source_direction)
	if blocked:
		_spawn_block_vfx(attack_type_value, source_direction)
		print("[Player] hurtbox blocked")
		return
	request_respawn(hit_reason)


func _update_block_state() -> void:
	if not _can_accept_action_input():
		is_blocking_physical = false
		is_blocking_magic = false
		if sprite:
			sprite.modulate = Color(1.0, 1.0, 1.0)
		return

	var physical = Input.is_action_pressed("block_physical")
	var magic = Input.is_action_pressed("block_magic")
	if _debug_force_block_physical >= 0:
		physical = _debug_force_block_physical == 1
	if _debug_force_block_magic >= 0:
		magic = _debug_force_block_magic == 1
	if physical and magic:
		magic = false

	is_blocking_physical = physical
	is_blocking_magic = magic

	if debug_log_state:
		if is_blocking_physical != _last_blocking_physical:
			print("[State] blocking_physical=", is_blocking_physical)
			_last_blocking_physical = is_blocking_physical
		if is_blocking_magic != _last_blocking_magic:
			print("[State] blocking_magic=", is_blocking_magic)
			_last_blocking_magic = is_blocking_magic

	if sprite:
		if is_blocking_magic:
			sprite.modulate = Color(0.5, 0.9, 1.0)
		elif is_blocking_physical:
			sprite.modulate = Color(0.85, 0.85, 0.85)
		else:
			sprite.modulate = Color(1.0, 1.0, 1.0)


func _start_attack() -> void:
	_transition_player_state(PlayerState.ATTACK)
	_play_attack_swing_sfx()
	print("[State] state -> ATTACK")


func _can_accept_action_input() -> bool:
	return (
		not _story_input_locked
		and _player_state != PlayerState.ATTACK
		and _player_state != PlayerState.HURT
		and _player_state != PlayerState.DEAD
	)


func set_story_input_locked(locked: bool) -> void:
	_story_input_locked = locked


func _apply_camera_horizon() -> void:
	if camera:
		camera.position.y = camera_horizon_offset_y


func _is_front_attack(source_direction: Vector2) -> bool:
	if source_direction.length_squared() <= 0.0001:
		return false
	var facing_direction: Vector2 = Vector2(_facing_dir, 0.0)
	return facing_direction.dot(source_direction.normalized()) >= 0.0


func _is_ground_blocking_locked() -> bool:
	return is_on_floor() and (is_blocking_physical or is_blocking_magic)


func _spawn_block_vfx(attack_type_value: int, source_direction: Vector2) -> void:
	var vfx: BlockImpactVfx = BlockImpactVfxScene.instantiate() as BlockImpactVfx
	if not vfx:
		return

	var parent_node: Node = get_parent()
	if not parent_node:
		return
	parent_node.add_child(vfx)

	var effect_direction: Vector2 = source_direction
	if effect_direction.length_squared() <= 0.0001:
		effect_direction = Vector2(_facing_dir, 0.0)
	else:
		effect_direction = effect_direction.normalized()

	var effect_type: StringName = PHYSICAL_BLOCK_VFX
	if attack_type_value == AttackTypeClass.Type.MAGIC:
		effect_type = MAGIC_BLOCK_VFX

	var effect_position: Vector2 = global_position + effect_direction * BLOCK_VFX_OFFSET
	vfx.play_once(effect_type, effect_position, _facing_dir)
	_play_block_sfx(attack_type_value)


func _play_jump_sfx() -> void:
	if procedural_sfx:
		procedural_sfx.play_jump(0.72)


func _play_attack_swing_sfx() -> void:
	if procedural_sfx:
		procedural_sfx.play_swing(0.80)


func _play_block_sfx(attack_type_value: int) -> void:
	if not procedural_sfx:
		return
	if attack_type_value == AttackTypeClass.Type.MAGIC:
		procedural_sfx.play_hit(0.66)
		return
	procedural_sfx.play_hit(0.82)


func _play_land_sfx_if_needed() -> void:
	var now_on_floor: bool = is_on_floor()
	if not _was_on_floor and now_on_floor and procedural_sfx:
		procedural_sfx.play_land(0.76)
	_was_on_floor = now_on_floor


func _apply_attack_hitbox_transform() -> void:
	if not attack_hit_box:
		return
	attack_hit_box.position = Vector2(
		_attack_hit_box_origin.x * _facing_dir, _attack_hit_box_origin.y
	)


func _update_state_machine(input_dir: float) -> void:
	if _player_state == PlayerState.ATTACK:
		return
	_transition_player_state(_resolve_non_attack_state(input_dir))


func _resolve_non_attack_state(input_dir: float) -> PlayerState:
	if not is_on_floor():
		if velocity.y < 0.0:
			return PlayerState.JUMP
		return PlayerState.FALL
	if is_blocking_physical or is_blocking_magic:
		if is_blocking_magic:
			return PlayerState.BLOCK_MAGIC
		return PlayerState.BLOCK_PHYSICAL
	if absf(input_dir) > 0.0:
		return PlayerState.WALK
	return PlayerState.IDLE


func _transition_player_state(next_state: PlayerState) -> void:
	if _player_state == next_state:
		return
	_player_state = next_state
	_play_animation(_state_to_animation(next_state))


func _state_to_animation(state: PlayerState) -> StringName:
	var animation_name: StringName = idle_animation_name
	match state:
		PlayerState.ATTACK:
			animation_name = attack_animation_name
		PlayerState.HURT:
			animation_name = hurt_animation_name
		PlayerState.DEAD:
			animation_name = death_animation_name
		PlayerState.BLOCK_PHYSICAL, PlayerState.BLOCK_MAGIC:
			animation_name = block_animation_name
		PlayerState.WALK:
			animation_name = walk_animation_name
		PlayerState.JUMP:
			animation_name = jump_animation_name
		PlayerState.FALL:
			animation_name = fall_animation_name
	return animation_name


func _play_animation(animation_name: StringName) -> void:
	if not animation_player:
		return
	var target_animation: StringName = animation_name
	if not animation_player.has_animation(target_animation):
		if (
			target_animation != idle_animation_name
			and animation_player.has_animation(idle_animation_name)
		):
			target_animation = idle_animation_name
		else:
			return
	if _current_visual_animation == target_animation:
		return
	_current_visual_animation = target_animation
	animation_player.play(target_animation)


func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == attack_animation_name and _player_state == PlayerState.ATTACK:
		var input_dir: float = Input.get_axis("move_left", "move_right")
		_transition_player_state(_resolve_non_attack_state(input_dir))
		print("[State] state <- ATTACK finished")
		return
	if anim_name == hurt_animation_name and _player_state == PlayerState.HURT:
		var input_dir_after_hurt: float = Input.get_axis("move_left", "move_right")
		_transition_player_state(_resolve_non_attack_state(input_dir_after_hurt))
		print("[State] state <- HURT finished")
		return
