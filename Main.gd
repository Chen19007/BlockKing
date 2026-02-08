extends Node

const GameFlowConfigClass = preload("res://system/GameFlowConfig.gd")

var current_section: Node2D = null
var current_section_id: String = ""
var current_checkpoint: Node2D = null
var is_loading_section: bool = false
var is_respawning: bool = false
var _player_scene: PackedScene = preload("res://player/Player.tscn")


func _ready() -> void:
	add_to_group("main")

	NodeReadyManager.register_node_ready_callback("Checkpoint", _on_checkpoint_ready)
	NodeReadyManager.register_node_ready_callback("Player", _on_player_ready)

	var first_stage = GameFlowConfigClass.get_first_stage_id()
	var first_section = GameFlowConfigClass.get_first_section_id(first_stage)
	if first_section != "":
		await load_section(first_section)
	else:
		print("[Main] No section found in GameFlowConfig")


func get_player_scene() -> PackedScene:
	return _player_scene


func get_current_section_id() -> String:
	return current_section_id


func set_current_checkpoint(checkpoint: Node2D) -> void:
	current_checkpoint = checkpoint


func unload_section() -> void:
	_hide_dialogue_ui()
	if not current_section:
		return
	_disconnect_section_signals()
	current_section.queue_free()
	current_section = null
	current_section_id = ""
	current_checkpoint = null


func load_section(section_id: String) -> void:
	if is_loading_section:
		return
	is_loading_section = true

	NodeReadyManager.reset_all()
	unload_section()
	var scene_path = GameFlowConfigClass.get_section_path(section_id)
	var packed_scene := load(scene_path) as PackedScene
	if not packed_scene:
		print("[Main] Failed to load section: ", scene_path)
		is_loading_section = false
		return
	current_section = packed_scene.instantiate()
	current_section.name = section_id
	current_section_id = section_id
	add_child(current_section)
	_connect_section_signals()
	await _spawn_player_at_checkpoint()
	await NodeReadyManager.wait_for_node_ready("Player")
	is_loading_section = false


func switch_section(target_section_id: String) -> void:
	if target_section_id == "":
		print("[Main] Reached last section, restarting stage")
		var first_stage = GameFlowConfigClass.get_first_stage_id()
		var first_section = GameFlowConfigClass.get_first_section_id(first_stage)
		if first_section != "":
			await load_section(first_section)
		return
	await load_section(target_section_id)


func _connect_section_signals() -> void:
	if not current_section:
		return
	var transport = current_section.get_node_or_null("Transport")
	if transport and transport.has_signal("section_transport_requested"):
		if not transport.section_transport_requested.is_connected(_on_transport_requested):
			transport.section_transport_requested.connect(_on_transport_requested)


func _disconnect_section_signals() -> void:
	if not current_section:
		return
	var transport = current_section.get_node_or_null("Transport")
	if transport and transport.has_signal("section_transport_requested"):
		if transport.section_transport_requested.is_connected(_on_transport_requested):
			transport.section_transport_requested.disconnect(_on_transport_requested)


func _on_transport_requested(target_section_id: String) -> void:
	print("[Main] Transport requested -> ", target_section_id)
	await switch_section(target_section_id)


func _spawn_player_at_checkpoint() -> void:
	if not current_section:
		return
	var checkpoint_node = current_section.get_node_or_null("Checkpoint")
	if not checkpoint_node:
		print("[Main] No Checkpoint in section")
		return
	await NodeReadyManager.wait_for_node_ready("Checkpoint")
	if current_checkpoint and current_checkpoint.has_method("spawn_player"):
		NodeReadyManager.clear_node_ready("Player")
		current_checkpoint.spawn_player()
		return
	print("[Main] Checkpoint not ready or missing spawn_player")


func _on_checkpoint_ready(_node_name: String, node: Node) -> void:
	current_checkpoint = node as Node2D


func _on_player_ready(_node_name: String, _node: Node) -> void:
	var player = _node
	if player and player.has_signal("respawn_requested"):
		if not player.respawn_requested.is_connected(_on_player_respawn_requested):
			player.respawn_requested.connect(_on_player_respawn_requested)
	_apply_camera_limits_to_player(player)


func _on_player_respawn_requested() -> void:
	if is_respawning:
		return
	is_respawning = true
	print("[Main] Respawn requested")
	await _respawn_player()
	is_respawning = false


func _respawn_player() -> void:
	if not current_checkpoint:
		print("[Main] No Checkpoint for respawn")
		return
	NodeReadyManager.clear_node_ready("Player")
	if current_checkpoint.has_method("spawn_player"):
		current_checkpoint.spawn_player()
		await NodeReadyManager.wait_for_node_ready("Player")
		print("[Main] Respawn complete")


func _apply_camera_limits_to_player(player: Node) -> void:
	if not player or not player.has_method("set_camera_limits"):
		return
	if not current_section or not current_section.has_method("get_camera_limits"):
		return
	var limits: Dictionary = current_section.get_camera_limits()
	player.call("set_camera_limits", limits)


func _hide_dialogue_ui() -> void:
	var dialogue_ui := get_node_or_null("DialogueUI") as DialogueUI
	if dialogue_ui:
		dialogue_ui.hide_dialogue()
