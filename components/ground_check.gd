class_name GroundCheck
extends Area2D

var is_grounded := false

func _on_body_entered(_body: Node2D) -> void:
	is_grounded = true
	if get_parent() is Coin:
		get_parent().is_shot_by_enemy = false


func _on_body_exited(_body: Node2D) -> void:
	is_grounded = false
