class_name StoryData
extends RefCounted

const STORY_DATA_ROOT: String = "res://story_data/"


static func get_dialogues(section_id: String) -> Dictionary:
	var data_path: String = STORY_DATA_ROOT + section_id + ".json"
	if not FileAccess.file_exists(data_path):
		push_warning("[StoryData] missing story data path=%s" % data_path)
		return {}

	var json_text: String = FileAccess.get_file_as_string(data_path)
	var json := JSON.new()
	var parse_error: int = json.parse(json_text)
	if parse_error != OK:
		push_warning(
			(
				"[StoryData] parse failed path=%s line=%d msg=%s"
				% [data_path, json.get_error_line(), json.get_error_message()]
			)
		)
		return {}

	var data_variant: Variant = json.data
	var data := data_variant as Dictionary
	if not data:
		push_warning("[StoryData] root is not dictionary path=%s" % data_path)
		return {}
	return data


static func get_lines(section_id: String, key: StringName) -> Array[String]:
	var dialogues: Dictionary = get_dialogues(section_id)
	var raw_lines: Variant = dialogues.get(String(key), [])
	var lines: Array[String] = []
	if raw_lines is Array:
		for line_variant in raw_lines:
			lines.append(str(line_variant))
	return lines
