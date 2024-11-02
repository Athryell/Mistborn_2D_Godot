extends RigidBody2D


func _ready() -> void:
	mass = 0.1


func _on_ground_check_body_entered(_body: Node2D) -> void:
	mass = 100


func _on_ground_check_body_exited(_body: Node2D) -> void:
	mass = 0.1
