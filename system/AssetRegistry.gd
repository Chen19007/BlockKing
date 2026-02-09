extends Node

const CONTRACT_PATH: String = "res://docs/asset_contracts.yaml"

var _asset_paths: Dictionary = {}
var _placeholder_paths: Dictionary = {}


func _ready() -> void:
	_load_contract()


func get_asset_path(asset_id: String) -> String:
	var real_path: String = str(_asset_paths.get(asset_id, ""))
	if real_path != "" and ResourceLoader.exists(real_path):
		return real_path

	var fallback_path: String = str(_placeholder_paths.get(asset_id, ""))
	if fallback_path != "" and ResourceLoader.exists(fallback_path):
		return fallback_path

	return ""


func get_texture(asset_id: String) -> Texture2D:
	var asset_path: String = get_asset_path(asset_id)
	if asset_path == "":
		push_warning("[AssetRegistry] texture missing asset_id=%s" % asset_id)
		return null
	var texture := load(asset_path) as Texture2D
	if texture == null:
		push_warning("[AssetRegistry] texture load failed asset_id=%s path=%s" % [asset_id, asset_path])
	return texture


func get_audio_stream(asset_id: String) -> AudioStream:
	var asset_path: String = get_asset_path(asset_id)
	if asset_path == "":
		push_warning("[AssetRegistry] audio missing asset_id=%s" % asset_id)
		return null
	var audio_stream := load(asset_path) as AudioStream
	if audio_stream == null:
		push_warning("[AssetRegistry] audio load failed asset_id=%s path=%s" % [asset_id, asset_path])
	return audio_stream


func get_font(asset_id: String) -> Font:
	var asset_path: String = get_asset_path(asset_id)
	if asset_path == "":
		push_warning("[AssetRegistry] font missing asset_id=%s" % asset_id)
		return null
	var font_resource := load(asset_path) as Font
	if font_resource == null:
		push_warning("[AssetRegistry] font load failed asset_id=%s path=%s" % [asset_id, asset_path])
	return font_resource


func has_asset(asset_id: String) -> bool:
	return get_asset_path(asset_id) != ""


func list_asset_ids() -> PackedStringArray:
	var keys: PackedStringArray = []
	for key in _asset_paths.keys():
		keys.append(str(key))
	keys.sort()
	return keys


func _load_contract() -> void:
	_asset_paths.clear()
	_placeholder_paths.clear()

	if not FileAccess.file_exists(CONTRACT_PATH):
		push_warning("[AssetRegistry] contract file not found path=%s" % CONTRACT_PATH)
		return

	var contract_text: String = FileAccess.get_file_as_string(CONTRACT_PATH)
	_parse_contract_text(contract_text)


func _to_res_path(path: String) -> String:
	if path == "":
		return ""
	if path.begins_with("res://"):
		return path
	return "res://%s" % path


func _parse_contract_text(contract_text: String) -> void:
	var current_asset_id: String = ""
	var current_target_path: String = ""
	var current_placeholder_path: String = ""

	for raw_line in contract_text.split("\n"):
		var line: String = raw_line.strip_edges()
		if line == "" or line.begins_with("#"):
			continue
		if line.begins_with("- asset_id:"):
			_commit_item(current_asset_id, current_target_path, current_placeholder_path)
			current_asset_id = _extract_value(line)
			current_target_path = ""
			current_placeholder_path = ""
			continue
		if line.begins_with("asset_id:"):
			_commit_item(current_asset_id, current_target_path, current_placeholder_path)
			current_asset_id = _extract_value(line)
			current_target_path = ""
			current_placeholder_path = ""
			continue
		if line.begins_with("target_path:"):
			current_target_path = _extract_value(line)
			continue
		if line.begins_with("placeholder_path:"):
			current_placeholder_path = _extract_value(line)
			continue

	_commit_item(current_asset_id, current_target_path, current_placeholder_path)


func _commit_item(asset_id: String, target_path: String, placeholder_path: String) -> void:
	if asset_id == "":
		return
	_asset_paths[asset_id] = _to_res_path(target_path)
	_placeholder_paths[asset_id] = _to_res_path(placeholder_path)


func _extract_value(line: String) -> String:
	var colon_index: int = line.find(":")
	if colon_index < 0:
		return ""
	var value: String = line.substr(colon_index + 1).strip_edges()
	if value.begins_with("\"") and value.ends_with("\"") and value.length() >= 2:
		value = value.substr(1, value.length() - 2)
	return value
