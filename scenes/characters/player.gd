extends RigidBody2D

@export var max_velocity := 300.0

const JUMP_STRENGTH := 500.0
const SPEED := 1500.0

var _direction = 0
var _is_grounded: bool = false

@onready var _ground_check_l = $GroundCheckLeft
@onready var _ground_check_r = $GroundCheckRight
@onready var _ground_check_m = $GroundCheckMiddle


func _process(delta):
	_is_grounded = _ground_check_l.get_collider() or _ground_check_m.get_collider() or _ground_check_r.get_collider()
	
	_direction = Input.get_axis("move_left", "move_right")
	if not _is_grounded:
		_direction *= 0.5
		


func _integrate_forces(state):
	if abs(state.linear_velocity.x) < max_velocity:
		state.apply_central_force(Vector2.RIGHT * _direction * SPEED)

	if Input.is_action_just_pressed("jump") and _is_grounded:
		state.apply_central_impulse(Vector2.UP * JUMP_STRENGTH)
