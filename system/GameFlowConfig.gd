class_name GameFlowConfig
extends RefCounted

static var game_flow: Array[Dictionary] = [
	{"stage_id": "stage1", "sections": ["section1_1", "section1_2"]}
]


static func get_stage_ids() -> Array:
	var stage_ids = []
	for stage_config in game_flow:
		stage_ids.append(stage_config.stage_id)
	return stage_ids


static func get_first_stage_id() -> String:
	if game_flow.size() > 0:
		return game_flow[0].stage_id
	return ""


static func get_stage_config(stage_id: String) -> Dictionary:
	for stage_config in game_flow:
		if stage_config.stage_id == stage_id:
			return stage_config
	return {}


static func get_section_ids(stage_id: String) -> Array:
	var config = get_stage_config(stage_id)
	return config.get("sections", [])


static func get_first_section_id(stage_id: String) -> String:
	var sections = get_section_ids(stage_id)
	if sections.size() > 0:
		return sections[0]
	return ""


static func get_next_section_id(current_section_id: String) -> String:
	var parts = current_section_id.replace("section", "").split("_")
	if parts.size() != 2:
		return ""
	var stage_id = "stage" + parts[0]
	var sections = get_section_ids(stage_id)
	var current_index = sections.find(current_section_id)
	if current_index >= 0 and current_index < sections.size() - 1:
		return sections[current_index + 1]
	return ""


static func get_stage_id_from_section(section_id: String) -> String:
	var parts = section_id.replace("section", "").split("_")
	if parts.size() != 2:
		return ""
	return "stage" + parts[0]


static func get_section_path(section_id: String) -> String:
	var stage_id = get_stage_id_from_section(section_id)
	return "res://stages/" + stage_id + "/" + section_id + ".tscn"
