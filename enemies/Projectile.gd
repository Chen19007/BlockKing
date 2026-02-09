extends Area2D

const AttackTypeClass = preload("res://system/AttackType.gd")
const CollisionLayersClass = preload("res://system/CollisionLayers.gd")
const PHYSICAL_PROJECTILE_TEXTURE = preload("res://assets/Projectile/Arrow01_32.png")
const MAGIC_PROJECTILE_TEXTURE = preload("res://assets/Projectile/WizardAttack02_frame0.png")

@export var speed: float = 360.0
@export var direction: Vector2 = Vector2.RIGHT
@export var attack_type: int = AttackTypeClass.Type.PHYSICAL
@export var lifetime_sec: float = 4.0
@export var is_reflectable: bool = true

var _elapsed: float = 0.0
var _reflected: bool = false

@onready var projectile_hit_box: HitBox = $HitBox
@onready var projectile_sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	if direction == Vector2.ZERO:
		direction = Vector2.RIGHT
	direction = direction.normalized()
	if projectile_hit_box:
		projectile_hit_box.attack_type = attack_type
		projectile_hit_box.hit_reason = "projectile"
		if not projectile_hit_box.hit.is_connected(_on_hit_box_hit):
			projectile_hit_box.hit.connect(_on_hit_box_hit)
	_update_projectile_visual()


func _physics_process(delta: float) -> void:
	if _is_story_playing():
		return
	position += direction * speed * delta
	_elapsed += delta
	if _elapsed >= lifetime_sec:
		queue_free()


func _on_hit_box_hit(target: HurtBox, source_direction: Vector2) -> void:
	var target_owner: Node = target.owner
	if not target_owner:
		return

	if target_owner.is_in_group("player"):
		var blocked: bool = false
		var player := target_owner as Player
		if player:
			blocked = player.can_block_attack_from(attack_type, source_direction)
		if blocked and is_reflectable and not _reflected:
			_reflected = true
			direction.x = -direction.x
			if projectile_hit_box:
				projectile_hit_box.collision_mask = CollisionLayersClass.ENEMY_HURT_BOX
			_update_projectile_visual()
			print("[Projectile] blocked -> reflect")
			return
		if blocked:
			print("[Projectile] blocked -> absorbed")
			queue_free()
			return
		print("[Projectile] hit_player blocked=", blocked)
		queue_free()
		return

	if _reflected and target_owner.is_in_group("enemy"):
		print("[Projectile] reflected_hit_enemy")
		queue_free()


func _update_projectile_visual() -> void:
	if not projectile_sprite:
		return
	if attack_type == AttackTypeClass.Type.MAGIC:
		projectile_sprite.texture = MAGIC_PROJECTILE_TEXTURE
		projectile_sprite.flip_h = direction.x < 0.0
	else:
		projectile_sprite.texture = PHYSICAL_PROJECTILE_TEXTURE
		projectile_sprite.flip_h = direction.x < 0.0


func get_attack_direction() -> Vector2:
	return direction


func _is_story_playing() -> bool:
	var runner: Node = get_node_or_null("/root/StoryEventRunner")
	if not runner:
		return false
	if not runner.has_method("is_story_playing"):
		return false
	return bool(runner.call("is_story_playing"))
