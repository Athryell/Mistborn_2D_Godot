extends RigidBody2D

const COIN = preload("res://scenes/props/coin.tscn")
const JUMP_STRENGTH := 20000.0
const SPEED := 150000.0

@export var max_velocity := 300.0

var _health: int:
	set(value):
		_health = value
		SignalBus.health_changed.emit(_health)

var _is_grounded := false:
	set(value):
		_is_grounded = value
		if _is_grounded and not _can_double_jump:
			_can_double_jump = true
var _is_agains_wall := false
var _is_sliding := false
var is_shooting := false
var _has_coin := false
var _is_double_jumping := false
var _jump_request := false
var _can_double_jump := false
var direction = 0
var coin_spawn_distance = 15
var coin
var is_dead := false

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var metal_detector: Area2D = $MetalDetector
@onready var _ground_check_l = $GroundChecks/GroundCheckLeft
@onready var _ground_check_r = $GroundChecks/GroundCheckRight
@onready var _ground_check_m = $GroundChecks/GroundCheckMiddle
@onready var wall_check_right: RayCast2D = $WallChecks/WallCheckRight
@onready var wall_check_left: RayCast2D = $WallChecks/WallCheckLeft
@onready var push_metal_radius: float = $MetalDetector/CollisionShape2D.shape.radius
@onready var _coins_container: Node = get_parent().get_node("Props/Coins")
@onready var hit_box: Area2D = $HitBox


func _ready() -> void:
	SignalBus.update_coin_ui.connect(func(amount: int): _has_coin = amount > 0)
	_health = Globals.STARTING_PLAYER_HEALTH


func _process(_delta):
	if is_dead:
		return
	_is_grounded = _ground_check_l.get_collider() or _ground_check_m.get_collider() or _ground_check_r.get_collider()
	_is_agains_wall = wall_check_left.get_collider() or wall_check_right.get_collider()
	_is_sliding = _is_agains_wall and not _is_grounded and linear_velocity.y > 0
	
	if not _is_sliding:
		set_linear_damp(0)
		direction = Input.get_axis("move_left", "move_right")
	else:
		set_linear_damp(20)
	
	_jump_request = Input.is_action_just_pressed("jump") and (_is_grounded or _is_sliding)
	
	if coin:
		if global_position.distance_to(coin.global_position) > push_metal_radius:
			is_shooting = false
			coin = null
	
	if Input.is_action_just_pressed("jump") and not _is_grounded and _can_double_jump and _has_coin:
		_can_double_jump = false
		_is_double_jumping = true
		shoot(Vector2.DOWN)
	if Input.is_action_just_released("jump"):
		_is_double_jumping = false
	
	#if not $MetalDetector.is_detecting_metals:
	if Input.is_action_just_pressed("push_metal") and _has_coin:
		is_shooting = true
		var dir = (get_global_mouse_position() - global_position).normalized()
		shoot(dir)
	elif Input.is_action_just_released("push_metal"):
		is_shooting = false
		coin = null
	
	if not _is_grounded:
		direction *= 0.2


func _integrate_forces(state):
	if abs(state.linear_velocity.x) < max_velocity:
		state.apply_central_force(Vector2.RIGHT * direction * SPEED)
	if _jump_request and not _is_sliding:
		state.apply_central_impulse(Vector2.UP * JUMP_STRENGTH)
	elif _jump_request and _is_sliding:
		var dir = Vector2(-1, -1) if  wall_check_right.get_collider() else Vector2(1, -1)
		state.apply_central_impulse(dir * JUMP_STRENGTH)
	if is_shooting or _is_double_jumping:
		metal_detector.apply_force_to_metal(coin, false)


func take_damage(amount: int) -> void:
	_health -= amount
	if _health <= 0:
		is_dead = true
		anim.die()

func shoot(dir: Vector2) -> void:
	hit_box.total_coins -= 1
	coin = COIN.instantiate()
	coin.global_position = global_position + dir * coin_spawn_distance
	_coins_container.add_child(coin)
	
	_apply_first_impulse()


func _apply_first_impulse() -> void:
	var force_direction = global_position - coin.global_position
	var distance = clamp(force_direction.length(), Globals.MAGNET_MIN_CLAMP, Globals.MAGNET_MAX_CLAMP)
	var force_strength = (mass * coin.mass) / (distance * distance) * Globals.MAGNET_FORCE_MODIFIER
	coin.apply_central_impulse(-force_direction.normalized() * force_strength)
