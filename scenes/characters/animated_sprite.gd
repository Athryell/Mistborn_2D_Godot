extends AnimatedSprite2D

@onready var parent = get_parent()

func _ready() -> void:
	play("idle")
	
func _process(_delta: float) -> void:
	set_animation("idle" if parent.direction == 0 else "run")
	
	if parent.direction > 0:
		set_flip_h(false)
		set_offset(Vector2(7, -6))
	elif parent.direction < 0:
		set_flip_h(true)
		set_offset(Vector2(-7, -6))

	if parent.linear_velocity.y > 50:
		set_animation("jump_end")
	elif parent.linear_velocity.y < -50:
		set_animation("jump_start")
