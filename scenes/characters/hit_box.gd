extends Area2D

@onready var parent := get_owner()
@onready var metal_detector: Area2D = $"../MetalDetector"

var total_coins := 0:
	set(value):
		total_coins = value
		SignalBus.update_coin_ui.emit(total_coins)
var _amount_potion_stored := 0

func _ready() -> void:
	SignalBus.potion_collected.connect(func(_p): _amount_potion_stored += 1)
	SignalBus.potion_drank.connect(func(_t, _f_a): _amount_potion_stored -= 1)

func _on_body_entered(body: Node2D) -> void:
	if body is Potion and _amount_potion_stored < Globals.MAX_PORTION_STORED:
		body.destroy()
		SignalBus.potion_collected.emit(body)
	elif body is Coin and body.is_shot_by_enemy:
		take_damage(1)
		#return
	elif body.is_in_group("coins"):
		if body.has_node("GroundCheck") and body.has_meta("value"):
			if parent.is_shooting or metal_detector.is_pulling or metal_detector.is_pushing:
				return
			if body.get_node("GroundCheck").is_grounded:
				total_coins += body.get_meta("value")
				body.destroy()
		else:
			push_error("No GroundCheck component or meta 'Value' for ", body)


func take_damage(amount: int) -> void:
	parent.take_damage(amount)
