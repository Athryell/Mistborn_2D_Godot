class_name BaseMetalObj
extends RigidBody2D

var is_grounded := false

func _on_ground_check_body_entered(_body: Node2D) -> void:
	is_grounded = true

func _on_ground_check_body_exited(_body: Node2D) -> void:
	is_grounded = false
