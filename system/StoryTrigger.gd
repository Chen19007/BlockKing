class_name StoryTrigger
extends Area2D

signal triggered(trigger_id: StringName)

@export var trigger_id: StringName = &""
@export var dialogue_lines: Array[String] = []
@export var trigger_once: bool = true
@export var pause_player_input: bool = true
@export var only_player: bool = true
@export var auto_disable: bool = true

var _has_triggered: bool = false


func _ready() -> void:
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)


func trigger() -> void:
	if trigger_once and _has_triggered:
		return
	_has_triggered = true
	if auto_disable:
		set_deferred("monitoring", false)
		set_deferred("monitorable", false)

	if not dialogue_lines.is_empty():
		var runner := get_node("/root/StoryEventRunner") as StoryEventRunner
		runner.play_dialogues(dialogue_lines, pause_player_input)

	emit_signal("triggered", trigger_id)


func _on_body_entered(body: Node2D) -> void:
	if only_player and not body.is_in_group("player"):
		return
	trigger()
