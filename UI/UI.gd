extends CanvasLayer

@onready var coins_info: Node2D = %CoinsContainer
@onready var potions_cointainer: Node2D = $PotionsCointainer

func _ready() -> void:
	SignalBus.update_coin_ui.connect(func (amount: int): coins_info.get_node("CoinsLabel").text = str(amount))
	coins_info.modulate.a = 0.0
	potions_cointainer.modulate.a = 0.0


func _on_show_coin_ui_trigger_body_entered(_body: Node2D) -> void:
	var tween = create_tween()
	tween.tween_property(coins_info, "modulate:a", 1.0, 2)


func _on_show_potions_ui_trigger_body_entered(_body: Node2D) -> void:
	var tween = create_tween()
	tween.tween_property(potions_cointainer, "modulate:a", 1.0, 2)
