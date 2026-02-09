class_name HUD
extends CanvasLayer

const HP_BAR_ASSET_ID: String = "ui.hud_hp_bar"
const HP_FILL_ASSET_ID: String = "ui.hud_hp_fill"
const GUARD_PHYSICAL_ASSET_ID: String = "ui.hud_guard_physical"
const GUARD_MAGIC_ASSET_ID: String = "ui.hud_guard_magic"
const OBJECTIVE_PANEL_ASSET_ID: String = "ui.hud_objective_panel"

const HP_FILL_FULL_WIDTH: float = 256.0
const GUARD_ACTIVE_COLOR: Color = Color(1.0, 1.0, 1.0, 1.0)
const GUARD_INACTIVE_COLOR: Color = Color(1.0, 1.0, 1.0, 0.35)

const OBJECTIVE_BY_SECTION: Dictionary = {
	"section0_tutorial": "当前目标：按提示学习格挡并前往右侧传送点",
	"section1_1": "当前目标：清理敌人并向右推进",
	"section1_2": "当前目标：击败施法敌人并前往出口"
}

var _player: Player = null
var _main: Node = null
var _last_section_id: String = ""

@onready var hp_bar: TextureRect = $TopLeft/HPBar
@onready var hp_fill: TextureRect = $TopLeft/HPFill
@onready var guard_physical: TextureRect = $TopLeft/GuardPhysical
@onready var guard_magic: TextureRect = $TopLeft/GuardMagic
@onready var objective_panel: TextureRect = $ObjectivePanel
@onready var objective_label: Label = $ObjectivePanel/ObjectiveLabel


func _ready() -> void:
	_apply_assets()
	objective_panel.visible = false
	_update_objective_text()
	_set_hp_ratio(1.0)


func _process(_delta: float) -> void:
	_refresh_refs()
	_update_guard_state()
	_update_objective_text()


func _apply_assets() -> void:
	var registry: Node = get_node_or_null("/root/AssetRegistry")
	if registry == null:
		push_warning("[HUD] missing /root/AssetRegistry")
		return
	if not registry.has_method("get_texture"):
		push_warning("[HUD] AssetRegistry.get_texture not found")
		return

	_assign_texture_from_asset(registry, hp_bar, HP_BAR_ASSET_ID)
	_assign_texture_from_asset(registry, hp_fill, HP_FILL_ASSET_ID)
	_assign_texture_from_asset(registry, guard_physical, GUARD_PHYSICAL_ASSET_ID)
	_assign_texture_from_asset(registry, guard_magic, GUARD_MAGIC_ASSET_ID)
	_assign_texture_from_asset(registry, objective_panel, OBJECTIVE_PANEL_ASSET_ID)


func _assign_texture_from_asset(registry: Node, node: TextureRect, asset_id: String) -> void:
	var texture_variant: Variant = registry.call("get_texture", asset_id)
	var texture := texture_variant as Texture2D
	if texture:
		node.texture = texture


func _refresh_refs() -> void:
	if _player == null or not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player") as Player
	if _main == null or not is_instance_valid(_main):
		_main = get_tree().get_first_node_in_group("main")


func _update_guard_state() -> void:
	var physical_active: bool = _player != null and _player.is_blocking_physical
	var magic_active: bool = _player != null and _player.is_blocking_magic
	guard_physical.modulate = GUARD_ACTIVE_COLOR if physical_active else GUARD_INACTIVE_COLOR
	guard_magic.modulate = GUARD_ACTIVE_COLOR if magic_active else GUARD_INACTIVE_COLOR


func _update_objective_text() -> void:
	var section_id: String = _get_current_section_id()
	if section_id == _last_section_id:
		return
	_last_section_id = section_id
	var objective: String = str(OBJECTIVE_BY_SECTION.get(section_id, "当前目标：继续向右推进"))
	objective_label.text = objective


func _get_current_section_id() -> String:
	if _main == null:
		return ""
	if _main.has_method("get_current_section_id"):
		return str(_main.call("get_current_section_id"))
	return str(_main.get("current_section_id"))


func _set_hp_ratio(ratio: float) -> void:
	var clamped: float = clampf(ratio, 0.0, 1.0)
	var size: Vector2 = hp_fill.size
	size.x = HP_FILL_FULL_WIDTH * clamped
	hp_fill.size = size
