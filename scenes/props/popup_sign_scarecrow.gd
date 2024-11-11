extends Sprite2D

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	SignalBus.scarecrow_appear.connect(_on_scarecrow_appear)
	sprite.position.y = 1


func _on_scarecrow_appear() -> void:
	var tween = create_tween()
	tween.tween_property(sprite, "position:y", 0, 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
