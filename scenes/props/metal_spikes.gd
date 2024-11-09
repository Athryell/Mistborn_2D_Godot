extends RigidBody2D

@export var damage := 5


func _on_hurt_box_area_entered(area: Area2D) -> void:
	if area.has_method("take_damage"):
		area.take_damage(damage)
	
