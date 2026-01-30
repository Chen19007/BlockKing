extends Area2D

const AttackTypeClass = preload("res://system/AttackType.gd")

@export var speed: float = 360.0
@export var direction: Vector2 = Vector2.RIGHT
@export var attack_type: int = AttackTypeClass.Type.PHYSICAL
@export var lifetime_sec: float = 4.0
@export var is_reflectable: bool = true

var _elapsed: float = 0.0
var _reflected: bool = false


func _ready() -> void:
	if direction == Vector2.ZERO:
		direction = Vector2.RIGHT
	direction = direction.normalized()
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	_elapsed += delta
	if _elapsed >= lifetime_sec:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var blocked := false
		if body is Player:
			blocked = body.is_blocking_for_attack(attack_type)
		if blocked and is_reflectable and not _reflected:
			_reflected = true
			direction.x = -direction.x
			print("[Projectile] blocked -> reflect")
			return
		print("[Projectile] hit_player blocked=", blocked)
		if body is Player:
			body.request_respawn("projectile")
		queue_free()
		return

	if _reflected and body.is_in_group("enemy"):
		print("[Projectile] reflected_hit_enemy")
		queue_free()
