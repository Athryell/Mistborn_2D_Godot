extends RigidBody2D

const COIN = preload("res://scenes/props/coin.tscn")
const JUMP_STRENGTH := 25000.0
const SPEED := 150000.0

@export var max_velocity := 300.0
@export var coin_shoot_distance := 25

var _is_grounded: bool = false
var _is_shooting := false
var _first_impulse := false
var direction = 0
var coin

@onready var _ground_check_l = $GroundCheckLeft
@onready var _ground_check_r = $GroundCheckRight
@onready var _ground_check_m = $GroundCheckMiddle
@onready var _coins_container: Node = get_parent().get_node("Coins")


func _process(_delta):
	_is_grounded = _ground_check_l.get_collider() or _ground_check_m.get_collider() or _ground_check_r.get_collider()
	
	direction = Input.get_axis("move_left", "move_right")
	
	if not $MetalDetector.is_detecting_metals:
		if Input.is_action_just_pressed("push_metal"):
			_is_shooting = true
			_first_impulse = true
			shoot()
		elif Input.is_action_just_released("push_metal"):
			_is_shooting = false
		
	if not _is_grounded:
		direction *= 0.5


func _integrate_forces(state):
	if abs(state.linear_velocity.x) < max_velocity:
		state.apply_central_force(Vector2.RIGHT * direction * SPEED)

	if Input.is_action_just_pressed("jump") and _is_grounded:
		state.apply_central_impulse(Vector2.UP * JUMP_STRENGTH)
	
	if _is_shooting:
		apply_coin_force()


func shoot() -> void:
	var mouse_pos = get_global_mouse_position()
	var dir = (mouse_pos - global_position).normalized()
	
	coin = COIN.instantiate()
	coin.global_position = global_position + dir
	#coin.global_position = global_position + dir * coin_shoot_distance
	_coins_container.add_child(coin)


func apply_coin_force() -> void:
	var force_direction = global_position - coin.global_position
	var distance = force_direction.length()
	distance = clamp(distance, Globals.MAGNET_MIN_CLAMP, Globals.MAGNET_MAX_CLAMP)
	var force_strength = (mass * coin.mass) / (distance * distance) * Globals.MAGNET_FORCE_MODIFIER
	
	#apply_central_impulse(force_direction.normalized() * force_strength)
	#coin.apply_central_impulse(-force_direction.normalized() * force_strength)
	
	var force_vector = force_direction.normalized() * force_strength
	apply_central_force(force_vector)
	if _first_impulse:
		_first_impulse = false
		coin.apply_central_impulse(-force_vector * 10)
	else:
		if coin.mass < 100:
			coin.apply_central_force(-force_vector)
