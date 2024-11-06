class_name GroundCheck
extends Area2D

var is_grounded := false

func _on_body_entered(_body: Node2D) -> void:
	is_grounded = true


func _on_body_exited(_body: Node2D) -> void:
	is_grounded = false
