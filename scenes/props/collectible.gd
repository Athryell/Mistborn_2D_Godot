class_name Collectible extends RigidBody2D

signal collectible_destroyed

func destroy() -> void:
	collectible_destroyed.emit()
	call_deferred("queue_free")
