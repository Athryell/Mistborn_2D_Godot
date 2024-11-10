extends Area2D

const COIN_POUCH = preload("res://scenes/collectibles/coin_pouch.tscn")
const COIN = preload("res://scenes/props/coin.tscn")

enum States {PUPPET, SCARECROW}

@export var initial_state: States = States.PUPPET
@export var hit_animation_timer := 0.1
@export var coin_spawn_distance := 17.0

var _states_data = {
	States.PUPPET: {"base_health": 3, "sprite": "SpritePuppet"},
	States.SCARECROW: {"base_health": 10, "sprite": "SpriteScarecrow", "starting_coins_held": 24},
}
var _health: int
var _sprite: Sprite2D
var _hit_direction
var _coins_left : int

@onready var _coins_container: Node =  get_tree().get_root().get_node("Main/Props/Coins")
@onready var coin_spawn_point: Marker2D = $CoinSpawnPoint
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var _state: States:
	set(value):
		_state = value
		_health = _states_data[_state].base_health
		if _sprite:
			_sprite.hide()
		_sprite = get_node(_states_data[_state].sprite)
		_sprite.show()


func _ready() -> void:
	_state = initial_state


func _on_body_entered(body: Node2D) -> void:
	_hit_direction = sign(body.get_linear_velocity().x)
	if body is Coin:
		body.destroy()
	_take_damage(1)


func _take_damage(amount: int) -> void:
	_health -= amount
	if _state == States.SCARECROW:
		_coins_left += 1
	if _health == 0:
		_go_to_next_state()
	
	_animate_hit()


func _animate_hit() -> void:
	var tween = create_tween().set_parallel()
	tween.tween_property(_sprite.material, "shader_parameter/white_amount", 1.0, hit_animation_timer)
	tween.tween_property(_sprite.material, "shader_parameter/wave_amount", 30.0 * _hit_direction, hit_animation_timer)
	tween.chain()
	tween.tween_property(_sprite.material, "shader_parameter/white_amount", 0.0, hit_animation_timer)
	tween.tween_property(_sprite.material, "shader_parameter/wave_amount", 0.0, hit_animation_timer)


func _go_to_next_state() -> void:
	match _state:
		States.PUPPET:
			_state = States.SCARECROW
			_coins_left = _states_data[States.SCARECROW].starting_coins_held
			$TimerAttack.start(1)
		States.SCARECROW:
			for i in 4:
				var new_pouch = COIN_POUCH.instantiate()
				new_pouch.global_position = global_position
				var rand_dir = Vector2(randi_range(-1, 1), randi_range(-1, 1))
				new_pouch.apply_central_impulse(rand_dir * 150)
				_coins_container.call_deferred("add_child", new_pouch)

			queue_free()


func _on_timer_attack_timeout() -> void:
	animation_player.play("attack")


func _shoot_coin(dir: Vector2) -> void:
	$TimerAttack.start(3)
	if _coins_left <= 0:
		return
	_coins_left -= 1
	var coin = COIN.instantiate()
	coin.is_shot_by_enemy = true
	var rand_dir_modifier = Vector2(dir.x, randf_range(-0.4, 0.4))
	coin.global_position = coin_spawn_point.global_position + rand_dir_modifier * coin_spawn_distance
	_coins_container.add_child(coin)
	var force_direction = coin_spawn_point.global_position - coin.global_position
	var distance = clamp(force_direction.length(), Globals.MAGNET_MIN_CLAMP, Globals.MAGNET_MAX_CLAMP)
	#var force_strength = (mass * coin.mass) / (distance * distance) * Globals.MAGNET_FORCE_MODIFIER
	var force_strength = (20 * coin.mass) / (distance * distance) * Globals.MAGNET_FORCE_MODIFIER
	coin.apply_central_impulse(-force_direction.normalized() * force_strength)
