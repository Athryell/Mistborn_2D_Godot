extends RigidBody2D

const COIN = preload("res://scenes/props/coin.tscn")
const JUMP_STRENGTH := 20000.0
const SPEED := 150000.0

@export var max_velocity := 300.0
@export var _damping_factor := 10.0
@export var _coyote_time = 0.2
@export var _jump_buffer_time = 0.2

var _health: int:
	set(value):
		_health = value
		SignalBus.health_changed.emit(_health)
var _is_grounded := true:
	set(value):
		_is_grounded = value
		if _is_grounded:
			_can_jump = true
		if _is_grounded and not _can_double_jump:
			_can_double_jump = true
var _is_agains_wall := false
var _is_sliding := false
var is_shooting := false
var _has_coin := false
var coyote_time_counter = 0.0 
var jump_buffer_counter = 0.0
var _is_double_jumping := false
var _jump_request := false
var _can_jump := false
var _can_double_jump := false
var direction = 0
var coin_spawn_distance = 15
var coin
var is_hit := false
var is_dead := false

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var metal_detector: Area2D = $MetalDetector
@onready var wall_check_right: RayCast2D = $WallChecks/WallCheckRight
@onready var wall_check_left: RayCast2D = $WallChecks/WallCheckLeft
@onready var push_metal_radius: float = $MetalDetector/CollisionShape2D.shape.radius
@onready var _coins_container: Node = get_parent().get_node("Props/Coins")
@onready var hit_box: Area2D = $HitBox


func _ready() -> void:
	SignalBus.update_coin_ui.connect(func(amount: int): _has_coin = amount > 0)
	_health = Globals.STARTING_PLAYER_HEALTH


func _process(delta):
	if is_dead or is_hit:
		return
	
	_is_agains_wall = wall_check_left.get_collider() or wall_check_right.get_collider()
	_is_sliding = _is_agains_wall and not _is_grounded and linear_velocity.y > 0
	
	if not _is_sliding:
		set_linear_damp(0)
		direction = Input.get_axis("move_left", "move_right")
		anim.last_facing_direction = direction
	else:
		set_linear_damp(20)
		
	_handle_jump(delta)

	if coin:
		if global_position.distance_to(coin.global_position) > push_metal_radius:
			is_shooting = false
			coin = null
	
	_handle_push_pull()


func _integrate_forces(state):
	var vel_x = abs(state.linear_velocity.x)
	if vel_x < max_velocity:
		if not _is_grounded:
			direction *= 0.2
		state.apply_central_force(Vector2.RIGHT * direction * SPEED)
	if direction == 0:
		state.linear_velocity.x *= (1 - _damping_factor * state.step)
	if _jump_request and not _is_sliding:
		state.apply_central_impulse(Vector2.UP * JUMP_STRENGTH)
	elif _jump_request and _is_sliding:
		var dir = Vector2(-1, -1) if  wall_check_right.get_collider() else Vector2(1, -1)
		state.apply_central_impulse(dir * JUMP_STRENGTH)
	_jump_request = false
	if is_shooting or _is_double_jumping and coin:
		metal_detector.apply_force_to_metal(coin, false)


func _handle_jump(delta) -> void:
	if coyote_time_counter > 0:
		coyote_time_counter -= delta
	if jump_buffer_counter > 0:
		jump_buffer_counter -= delta
	
	if _is_grounded or _is_sliding:
		coyote_time_counter = _coyote_time
	
	if Input.is_action_just_pressed("jump"):
		if not _is_grounded and _can_double_jump and _has_coin and not _is_sliding and not _can_jump:
		#if coyote_time_counter <= 0 or jump_buffer_counter <= 0:
			_can_double_jump = false
			_is_double_jumping = true
			shoot(Vector2.DOWN)
		else:
			jump_buffer_counter = _jump_buffer_time
	if Input.is_action_just_released("jump"):
		_is_double_jumping = false
	
	if coyote_time_counter > 0 and jump_buffer_counter > 0:
		if not _can_jump:
			return
		_jump_request = true
		_can_jump = false
		jump_buffer_counter = 0
		coyote_time_counter = 0

func _handle_push_pull() -> void:
		#if not $MetalDetector.is_detecting_metals:
	if Input.is_action_just_pressed("push_metal") and _has_coin:
		is_shooting = true
		var dir = (get_global_mouse_position() - global_position).normalized()
		shoot(dir)
	elif Input.is_action_just_released("push_metal"):
		is_shooting = false
		coin = null
	

func take_damage(amount: int) -> void:
	_health -= amount
	if _health <= 0:
		is_dead = true
		anim.die()
	is_hit = true
	anim.hit()


func shoot(dir: Vector2) -> void:
	hit_box.total_coins -= 1
	coin = COIN.instantiate()
	coin.collectible_destroyed.connect(_on_collectible_destroyed)
	coin.global_position = global_position + dir * coin_spawn_distance
	_coins_container.add_child(coin)
	
	_apply_first_impulse()


func _on_collectible_destroyed() -> void:
	coin = null
	is_shooting = false


func _apply_first_impulse() -> void:
	var force_direction = global_position - coin.global_position
	var distance = clamp(force_direction.length(), Globals.MAGNET_MIN_CLAMP, Globals.MAGNET_MAX_CLAMP)
	var force_strength = (mass * coin.mass) / (distance * distance) * Globals.MAGNET_FORCE_MODIFIER
	coin.apply_central_impulse(-force_direction.normalized() * force_strength)


func _on_ground_check_body_entered(_body: Node2D) -> void:
	_is_grounded = true


func _on_ground_check_body_exited(_body: Node2D) -> void:
	_is_grounded = false
