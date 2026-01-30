extends Area2D

signal section_transport_requested(target_section_id: String)

const GameFlowConfigClass = preload("res://system/GameFlowConfig.gd")

@export var teleport_to_respawn: bool = true
@export var target_section_id: String = ""

var is_teleporting: bool = false


func _ready() -> void:
	if target_section_id == "":
		var section = get_parent()
		if section and "section_id" in section:
			target_section_id = GameFlowConfigClass.get_next_section_id(section.section_id)
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if is_teleporting:
		return
	if body.name != "Player":
		return
	is_teleporting = true
	call_deferred("_emit_transport_request")
	await get_tree().create_timer(0.2).timeout
	is_teleporting = false


func _emit_transport_request() -> void:
	section_transport_requested.emit(target_section_id)
