extends Node2D

const STORY_DATA_CLASS = preload("res://system/StoryData.gd")

@export var section_id: String = "section1_1"
@export var respawn_point: Vector2 = Vector2.ZERO
@export var camera_limit_enabled: bool = false
@export var camera_limit_left: float = -INF
@export var camera_limit_right: float = INF
@export var camera_limit_top: float = -INF
@export var camera_limit_bottom: float = INF

@onready var respawn_marker: Node2D = get_node_or_null("RespawnPoint")
@onready var intro_trigger: StoryTrigger = get_node_or_null("TriggerIntro") as StoryTrigger


func _ready() -> void:
	if respawn_marker:
		respawn_point = respawn_marker.position
	_apply_intro_dialogues()


func get_respawn_point() -> Vector2:
	if respawn_marker:
		return respawn_marker.position
	return respawn_point


func set_respawn_point(new_point: Vector2) -> void:
	respawn_point = new_point
	if respawn_marker:
		respawn_marker.position = new_point
	print("[Section] respawn_point set to ", new_point)


func get_camera_limits() -> Dictionary:
	if not camera_limit_enabled:
		return {"enabled": false, "left": -INF, "right": INF, "top": -INF, "bottom": INF}
	var section_global_pos = global_position
	return {
		"enabled": true,
		"left": section_global_pos.x + camera_limit_left,
		"right": section_global_pos.x + camera_limit_right,
		"top": section_global_pos.y + camera_limit_top,
		"bottom": section_global_pos.y + camera_limit_bottom
	}


func _apply_intro_dialogues() -> void:
	if intro_trigger == null:
		return
	var intro_lines: Array[String] = STORY_DATA_CLASS.get_lines(section_id, &"intro")
	if intro_lines.is_empty():
		return
	intro_trigger.dialogue_lines = intro_lines
