extends AnimatedSprite2D

@onready var parent = get_parent()

func _ready() -> void:
	play("idle")


func _process(_delta: float) -> void:
	if parent.is_dead:
		return
	if parent._is_grounded:
		set_animation("idle" if parent.direction == 0 else "run")
	elif parent._is_sliding:
		set_animation("slide")
		if parent.wall_check_left.get_collider():
			set_flip_h(true)
			set_offset(Vector2(-11, -2))
		elif parent.wall_check_right.get_collider():
			set_flip_h(false)
			set_offset(Vector2(11, -2))
	
	if parent.linear_velocity.y > 50 and not parent._is_grounded and not parent._is_sliding:
		set_animation("jump_end")
	elif parent.linear_velocity.y < -50 and not parent._is_grounded and not parent._is_sliding:
		set_animation("jump_start")
		
	flip()


func flip():
	if parent._is_sliding:
		return
	if parent.linear_velocity.x > 0:
		set_flip_h(false)
		set_offset(Vector2(7, -6))
	elif parent.linear_velocity.x < 0:
		set_flip_h(true)
		set_offset(Vector2(-7, -6))


func die():
	set_animation("die")
	await animation_looped
	get_tree().reload_current_scene()
