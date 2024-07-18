extends RigidBody2D

const SPEED := 1500.0
@export var JUMP_STRENGTH := 1000.0

var direction = 0

func _process(delta):
	direction = Input.get_axis("move_left", "move_right")
	print(direction)

func _integrate_forces(state):
	state.apply_central_force(Vector2.RIGHT * direction * SPEED)

	if Input.is_action_just_pressed("jump"):
		state.apply_central_impulse(Vector2.UP * JUMP_STRENGTH)
