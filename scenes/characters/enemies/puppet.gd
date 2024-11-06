extends Area2D

const COIN_POUCH = preload("res://scenes/collectibles/coin_pouch.tscn")

enum States {PUPPET, SCARECROW}

@export var initial_state: States = States.PUPPET
@export var hit_animation_timer := 0.1

var _states_data = {
	States.PUPPET: {"base_health": 3, "sprite": "SpritePuppet"},
	States.SCARECROW: {"base_health": 10, "sprite": "SpriteScarecrow"},
}
var _health: int
var _sprite: Sprite2D
var _hit_direction

@onready var _coins_container: Node =  get_tree().get_root().get_node("Main/Props/Coins")

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
	_take_damage(1)


func _take_damage(amount: int) -> void:
	prints("damaged for", amount)
	_health -= amount
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
			#change sprite image
			#maybe hitbox size
			#maybe animation
		States.SCARECROW:
			for i in 4:
				var new_pouch = COIN_POUCH.instantiate()
				new_pouch.global_position = global_position
				_coins_container.add_child(new_pouch)
				var rand_dir = Vector2(randi_range(-1, 1), randi_range(-1, 1))
				new_pouch.apply_central_impulse(rand_dir * 100)
				
			call_deferred("queue_free")
