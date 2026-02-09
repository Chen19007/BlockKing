class_name DialogueUI
extends CanvasLayer

const PORTRAIT_FALLBACK_ASSET_ID: String = "portrait.narrator"
const PORTRAIT_FRAME_ASSET_ID: String = "portrait.narrator_frame"
const PORTRAIT_CHARACTER_ASSET_ID: String = "portrait.narrator_character"
const UI_SERIF_FONT_ASSET_ID: String = "font.ui_serif_cn"
const TEXT_PARCHMENT_SHADER_PATH: String = "res://ui/shaders/text_parchment.gdshader"
const DIALOGUE_SCREENSHOT_PATH: String = "user://dialogue_preview.png"
const DIALOGUE_SCREENSHOT_EDITOR_PATH: String = "res://dialogue_preview.png"
const TEXT_INK_COLOR: Color = Color8(33, 28, 26)
const TEXT_OUTLINE_COLOR: Color = Color8(245, 235, 214, 163)
const TEXT_SHADOW_COLOR: Color = Color8(23, 17, 13, 122)
const TEXT_SHADOW_OFFSET_PX: int = 2

@onready var dialog_box: TextureRect = $DialogBox
@onready var dialog_text: Label = $DialogBox/DialogText
@onready var portrait_frame: TextureRect = $DialogBox/PortraitFrame
@onready var portrait_character: TextureRect = $DialogBox/PortraitCharacter
@onready var ui_audio: AudioStreamPlayer = $UIAudio
@onready var procedural_sfx: Node = (
	get_node_or_null("/root/ProceduralSFXService") as Node
)


func _ready() -> void:
	visible = false
	_apply_assets()


func show_dialogue(text: String) -> void:
	visible = true
	dialog_text.text = text
	if procedural_sfx:
		procedural_sfx.play_click(0.55)
	elif ui_audio and ui_audio.stream:
		ui_audio.play()


func hide_dialogue() -> void:
	visible = false


func capture_dialogue_screenshot(save_path: String = DIALOGUE_SCREENSHOT_PATH) -> void:
	if not visible:
		push_warning("[DialogueUI] screenshot skipped: dialogue is hidden")
		return

	await RenderingServer.frame_post_draw
	var image: Image = get_viewport().get_texture().get_image()
	var err: Error = image.save_png(save_path)
	if err != OK:
		push_warning("[DialogueUI] screenshot save failed: %s" % save_path)
		return

	var absolute_path: String = ProjectSettings.globalize_path(save_path)
	print("[DialogueUI] screenshot saved: %s" % absolute_path)

	# Editor fallback: save one copy directly in project root for quick pickup.
	if OS.has_feature("editor"):
		var editor_err: Error = image.save_png(DIALOGUE_SCREENSHOT_EDITOR_PATH)
		if editor_err == OK:
			var editor_absolute: String = ProjectSettings.globalize_path(
				DIALOGUE_SCREENSHOT_EDITOR_PATH
			)
			print("[DialogueUI] screenshot saved: %s" % editor_absolute)


func _apply_assets() -> void:
	var registry: Node = get_node_or_null("/root/AssetRegistry")
	if registry == null:
		push_warning("[DialogueUI] missing /root/AssetRegistry")
		return

	if not registry.has_method("get_texture") or not registry.has_method("get_audio_stream"):
		push_warning("[DialogueUI] AssetRegistry methods not found")
		return

	var dialog_texture_variant: Variant = registry.call("get_texture", "ui.dialog_box")
	var dialog_texture := dialog_texture_variant as Texture2D
	if dialog_texture:
		dialog_box.texture = dialog_texture
	_apply_portrait_assets(registry)
	_apply_text_style(registry)

	var next_sfx_variant: Variant = registry.call("get_audio_stream", "sfx.ui_next")
	var next_sfx := next_sfx_variant as AudioStream
	if next_sfx:
		ui_audio.stream = next_sfx


func _apply_portrait_assets(registry: Node) -> void:
	var frame_texture: Texture2D = _get_texture_from_registry(registry, PORTRAIT_FRAME_ASSET_ID)
	var character_texture: Texture2D = _get_texture_from_registry(
		registry, PORTRAIT_CHARACTER_ASSET_ID
	)
	var fallback_texture: Texture2D = _get_texture_from_registry(registry, PORTRAIT_FALLBACK_ASSET_ID)

	if frame_texture and character_texture:
		portrait_frame.texture = frame_texture
		portrait_character.texture = character_texture
		portrait_frame.visible = true
		portrait_character.visible = true
		return

	if fallback_texture:
		portrait_character.texture = fallback_texture
		portrait_character.visible = true
		portrait_frame.visible = false
		return

	portrait_frame.visible = false
	portrait_character.visible = false


func _get_texture_from_registry(registry: Node, asset_id: String) -> Texture2D:
	if not registry.has_method("get_texture"):
		return null
	var texture_variant: Variant = registry.call("get_texture", asset_id)
	return texture_variant as Texture2D


func _apply_text_style(registry: Node) -> void:
	if registry.has_method("get_font"):
		var font_variant: Variant = registry.call("get_font", UI_SERIF_FONT_ASSET_ID)
		var serif_font := font_variant as Font
		if serif_font:
			dialog_text.add_theme_font_override("font", serif_font)

	dialog_text.add_theme_color_override("font_color", TEXT_INK_COLOR)
	dialog_text.add_theme_color_override("font_outline_color", TEXT_OUTLINE_COLOR)
	dialog_text.add_theme_color_override("font_shadow_color", TEXT_SHADOW_COLOR)
	dialog_text.add_theme_constant_override("outline_size", 1)
	dialog_text.add_theme_constant_override("shadow_offset_x", TEXT_SHADOW_OFFSET_PX)
	dialog_text.add_theme_constant_override("shadow_offset_y", TEXT_SHADOW_OFFSET_PX)

	if ResourceLoader.exists(TEXT_PARCHMENT_SHADER_PATH):
		var shader := load(TEXT_PARCHMENT_SHADER_PATH) as Shader
		if shader:
			var shader_material := ShaderMaterial.new()
			shader_material.shader = shader
			shader_material.set_shader_parameter("ink_color", TEXT_INK_COLOR)
			shader_material.set_shader_parameter("outline_color", TEXT_OUTLINE_COLOR)
			shader_material.set_shader_parameter("shadow_color", TEXT_SHADOW_COLOR)
			shader_material.set_shader_parameter("outline_size", 1.0)
			shader_material.set_shader_parameter(
				"shadow_offset", Vector2(float(TEXT_SHADOW_OFFSET_PX), float(TEXT_SHADOW_OFFSET_PX))
			)
			shader_material.set_shader_parameter("erosion_strength", 0.02)
			dialog_text.material = shader_material
