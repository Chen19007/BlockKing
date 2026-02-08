class_name HitBox
extends Area2D

signal hit(target: HurtBox, source_direction: Vector2)

@export var attack_type: int = 0
@export var hit_reason: String = ""


func _ready() -> void:
	add_to_group("hitbox")
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area2D) -> void:
	var hurt_box := area as HurtBox
	if not hurt_box:
		return
	var source_direction: Vector2 = global_position - hurt_box.global_position
	if source_direction.length_squared() > 0.0001:
		source_direction = source_direction.normalized()
	else:
		source_direction = Vector2.ZERO
	hurt_box.take_hit(self, source_direction)
	hit.emit(hurt_box, source_direction)
