class_name Player
extends CharacterBody2D

signal respawn_requested
const AttackType = preload("res://system/AttackType.gd")
const GameFlowConfig = preload("res://system/GameFlowConfig.gd")
const ProjectileScene = preload("res://enemies/Projectile.tscn")

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

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

var is_blocking_physical: bool = false
var is_blocking_magic: bool = false
var _respawn_queued: bool = false
var _e2e_move_remaining: float = 0.0
var _debug_force_block_physical: int = -1
var _debug_force_block_magic: int = -1

var _last_logged_position: Vector2 = Vector2.ZERO
var _last_input_dir: float = 0.0
var _last_blocking_physical: bool = false
var _last_blocking_magic: bool = false

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	add_to_group("player")
	NodeReadyManager.notify_node_ready("Player", self)
	_last_logged_position = global_position


func _physics_process(delta: float) -> void:
	_update_block_state()

	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_velocity

	var input_dir = Input.get_axis("move_left", "move_right")
	if absf(_e2e_move_remaining) > 0.0:
		var step = e2e_move_speed * delta
		var dir = signf(_e2e_move_remaining)
		var applied = minf(absf(_e2e_move_remaining), step) * dir
		_e2e_move_remaining -= applied
		velocity.x = applied / maxf(delta, 0.0001)
		if absf(_e2e_move_remaining) <= 0.01:
			_e2e_move_remaining = 0.0
	else:
		if is_blocking_physical or is_blocking_magic:
			velocity.x = 0.0
		else:
			velocity.x = input_dir * move_speed

	move_and_slide()

	if global_position.y > fall_respawn_y:
		request_respawn("fall")

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
			_spawn_test_projectile(AttackType.Type.PHYSICAL)
		KEY_F6:
			_spawn_test_projectile(AttackType.Type.MAGIC)
		KEY_PAGEUP:
			_e2e_switch_section(true)
		KEY_PAGEDOWN:
			_e2e_switch_section(false)
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

	get_tree().set_input_as_handled()
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
		target_id = GameFlowConfig.get_next_section_id(current_id)
	else:
		var first_stage = GameFlowConfig.get_first_stage_id()
		target_id = GameFlowConfig.get_first_section_id(first_stage)

	if not main_node.has_method("switch_section"):
		print("[E2E] switch_section skipped (Main missing switch_section)")
		return

	main_node.call_deferred("switch_section", target_id)
	print("[E2E] switch_section target=", target_id)


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
	if attack_type == AttackType.Type.PHYSICAL:
		return is_blocking_physical
	if attack_type == AttackType.Type.MAGIC:
		return is_blocking_magic
	return false


func request_respawn(reason: String = "") -> void:
	if _respawn_queued:
		return
	_respawn_queued = true
	print("[State] respawn requested reason=", reason)
	respawn_requested.emit()


func _update_block_state() -> void:
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
