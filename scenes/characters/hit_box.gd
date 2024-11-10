extends Area2D

@onready var parent := get_owner()
@onready var metal_detector: Area2D = $"../MetalDetector"

var total_coins := 0:
	set(value):
		total_coins = value
		SignalBus.update_coin_ui.emit(total_coins)


func _on_body_entered(body: Node2D) -> void:
	if body is Coin and body.is_shot_by_enemy:
		take_damage(1)
		return
	if body.is_in_group("coins"):
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
