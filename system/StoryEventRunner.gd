extends Node

signal story_started
signal story_finished

var advance_action: StringName = &"attack"

var _is_playing: bool = false
var _lines: Array[String] = []
var _line_index: int = 0
var _pause_player_input: bool = true


func _ready() -> void:
	set_process_unhandled_input(true)


func play_dialogues(lines: Array[String], pause_player_input: bool = true) -> void:
	if lines.is_empty():
		return

	_lines = lines
	_line_index = 0
	_pause_player_input = pause_player_input
	_is_playing = true

	if _pause_player_input:
		await _lock_player_input(true)

	emit_signal("story_started")
	_show_current_line()


func _unhandled_input(event: InputEvent) -> void:
	if not _is_playing:
		return
	if event.is_action_pressed(advance_action):
		_advance_line()
		get_tree().set_input_as_handled()


func _advance_line() -> void:
	if not _is_playing:
		return
	_line_index += 1
	if _line_index >= _lines.size():
		_finish()
		return
	_show_current_line()


func _finish() -> void:
	_is_playing = false
	_hide_dialogue()
	if _pause_player_input:
		_lock_player_input(false)
	emit_signal("story_finished")


func _show_current_line() -> void:
	var dialogue_ui := _get_dialogue_ui()
	if not dialogue_ui:
		return
	dialogue_ui.show_dialogue(_lines[_line_index])


func _hide_dialogue() -> void:
	var dialogue_ui := _get_dialogue_ui()
	if not dialogue_ui:
		return
	dialogue_ui.hide_dialogue()


func _get_dialogue_ui() -> DialogueUI:
	var main_node: Node = get_tree().get_first_node_in_group("main")
	if not main_node:
		push_warning("[StoryEventRunner] missing main group node")
		return null
	var dialogue_ui := main_node.get_node_or_null("DialogueUI") as DialogueUI
	if not dialogue_ui:
		push_warning("[StoryEventRunner] missing DialogueUI on main")
	return dialogue_ui


func _lock_player_input(locked: bool) -> void:
	if locked:
		await NodeReadyManager.wait_for_node_ready("Player")
	var player := get_tree().get_first_node_in_group("player") as Player
	if player:
		player.set_story_input_locked(locked)
