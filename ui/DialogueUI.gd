class_name DialogueUI
extends CanvasLayer

@onready var dialog_box: TextureRect = $DialogBox
@onready var dialog_text: Label = $DialogBox/DialogText
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

	var next_sfx_variant: Variant = registry.call("get_audio_stream", "sfx.ui_next")
	var next_sfx := next_sfx_variant as AudioStream
	if next_sfx:
		ui_audio.stream = next_sfx
