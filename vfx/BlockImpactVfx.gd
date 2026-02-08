class_name BlockImpactVfx
extends Node2D

const PHYSICAL_ANIM: StringName = &"block_physical_spark"
const MAGIC_ANIM: StringName = &"block_magic_shield"
const PHYSICAL_DIR: String = "res://assets/VFX/block_physical_spark/frames"
const MAGIC_DIR: String = "res://assets/VFX/block_magic_shield/frames"
const ANIMATION_FPS: float = 12.0

static var _shared_frames: SpriteFrames = null

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	_ensure_frames_loaded()


func play_once(effect_type: StringName, world_pos: Vector2, facing_dir: float = 1.0) -> void:
	_ensure_frames_loaded()
	global_position = world_pos
	animated_sprite.flip_h = facing_dir < 0.0

	if not animated_sprite.sprite_frames:
		queue_free()
		return
	if not animated_sprite.sprite_frames.has_animation(effect_type):
		queue_free()
		return
	if animated_sprite.sprite_frames.get_frame_count(effect_type) <= 0:
		queue_free()
		return

	animated_sprite.animation = effect_type
	animated_sprite.play()

	if not animated_sprite.animation_finished.is_connected(_on_animation_finished):
		animated_sprite.animation_finished.connect(_on_animation_finished, CONNECT_ONE_SHOT)


func _ensure_frames_loaded() -> void:
	if _shared_frames == null:
		_shared_frames = SpriteFrames.new()
		_add_animation_from_dir(_shared_frames, PHYSICAL_ANIM, PHYSICAL_DIR)
		_add_animation_from_dir(_shared_frames, MAGIC_ANIM, MAGIC_DIR)
	animated_sprite.sprite_frames = _shared_frames


func _add_animation_from_dir(
	sprite_frames: SpriteFrames, anim_name: StringName, dir_path: String
) -> void:
	if sprite_frames.has_animation(anim_name):
		sprite_frames.remove_animation(anim_name)
	sprite_frames.add_animation(anim_name)
	sprite_frames.set_animation_speed(anim_name, ANIMATION_FPS)
	sprite_frames.set_animation_loop(anim_name, false)

	var filenames: Array[String] = _list_png_files(dir_path)
	for filename in filenames:
		var texture: Texture2D = load(dir_path + "/" + filename) as Texture2D
		if texture:
			sprite_frames.add_frame(anim_name, texture)


func _list_png_files(dir_path: String) -> Array[String]:
	var results: Array[String] = []
	var dir: DirAccess = DirAccess.open(dir_path)
	if dir == null:
		return results

	dir.list_dir_begin()
	while true:
		var file_name: String = dir.get_next()
		if file_name == "":
			break
		if dir.current_is_dir():
			continue
		if file_name.to_lower().ends_with(".png"):
			results.append(file_name)
	dir.list_dir_end()

	results.sort()
	return results


func _on_animation_finished() -> void:
	queue_free()
