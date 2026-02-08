class_name HurtBox
extends Area2D

signal hurt(from: HitBox, source_direction: Vector2)


func _ready() -> void:
	add_to_group("hurtbox")


func take_hit(from: HitBox, source_direction: Vector2 = Vector2.ZERO) -> void:
	hurt.emit(from, source_direction)
