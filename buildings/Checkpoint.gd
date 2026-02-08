extends Area2D

signal checkpoint_activated

const CollisionLayersClass = preload("res://system/CollisionLayers.gd")

var spawned_player: Node = null
var _activated: bool = false


func _ready() -> void:
	collision_layer = CollisionLayersClass.WORLD_PHYSICS
	collision_mask = CollisionLayersClass.PLAYER_PHYSICS
	NodeReadyManager.notify_node_ready("Checkpoint", self)
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	_activate_checkpoint()


func _activate_checkpoint() -> void:
	if _activated:
		return
	_activated = true

	var section = get_parent()
	if section and section.has_method("set_respawn_point"):
		section.set_respawn_point(position)

	var main = get_tree().get_first_node_in_group("main")
	if main and main.has_method("set_current_checkpoint"):
		main.set_current_checkpoint(self)

	print("[Checkpoint] activated pos=", position)
	checkpoint_activated.emit()


func spawn_player() -> void:
	var section = get_parent()
	var has_existing_player: bool = false
	if section:
		for child in section.get_children():
			if not (child is Node2D):
				continue
			if child.is_in_group("player"):
				has_existing_player = true
				child.queue_free()
	if has_existing_player:
		await get_tree().process_frame

	if spawned_player and is_instance_valid(spawned_player):
		spawned_player.queue_free()
		await get_tree().process_frame

	var main = get_tree().get_first_node_in_group("main")
	if not main or not main.has_method("get_player_scene"):
		print("[Checkpoint] Main missing or get_player_scene not found")
		return

	var player_scene: PackedScene = main.get_player_scene()
	if not player_scene:
		print("[Checkpoint] Player scene missing")
		return

	spawned_player = player_scene.instantiate()
	if not spawned_player:
		print("[Checkpoint] Failed to instantiate Player")
		return

	spawned_player.name = "Player"
	section = get_parent()
	if section:
		section.add_child(spawned_player)
		spawned_player.position = position
		if section.has_method("get_respawn_point"):
			spawned_player.position = section.get_respawn_point()
	else:
		add_child(spawned_player)
		spawned_player.position = position
