extends AnimatedSprite2D

var hit_animation_timer = 0.1
var last_facing_direction: int = 0:
	set(value):
		last_facing_direction = value
		_flip(value)

@onready var parent = get_parent()

func _ready() -> void:
	play("idle")


func _process(_delta: float) -> void:
	if parent.is_dead or parent.is_hit:
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
		


func _flip(value: int):
	if parent._is_sliding:
		return
	if value == 1:
		set_flip_h(false)
		set_offset(Vector2(7, -6))
	elif value == -1:
		set_flip_h(true)
		set_offset(Vector2(-7, -6))


func hit() -> void:
	set_animation("hit")
	_animate_hit()
	await animation_looped
	parent.is_hit = false


func _animate_hit() -> void:
	var tween = create_tween()
	tween.tween_property(material, "shader_parameter/white_amount", 1.0, hit_animation_timer)
	tween.tween_property(material, "shader_parameter/white_amount", 0.0, hit_animation_timer)


func die() -> void:
	if animation.contains("die"):
		return
	set_animation("die")
	await animation_looped
	get_tree().reload_current_scene()
