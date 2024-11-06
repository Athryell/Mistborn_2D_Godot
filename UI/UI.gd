extends CanvasLayer

@onready var coins_label: Label = %CoinsLabel

func _ready() -> void:
	SignalBus.update_coin_ui.connect(func (amount: int): coins_label.text = str(amount))
	coins_label.self_modulate.a = 0.0

func _on_show_coin_ui_trigger_body_entered(_body: Node2D) -> void:
	var tween = create_tween()
	tween.tween_property(coins_label, "self_modulate:a", 1.0, 2)
