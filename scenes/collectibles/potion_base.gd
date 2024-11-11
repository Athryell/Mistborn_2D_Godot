@tool
class_name Potion
extends Collectible

@export var potion_type : Globals.PotionType = Globals.PotionType.EMPTY:
	set(value):
		potion_type = value
		if sprite:
			_setup(value)
@export var fill_amount := 100

@onready var sprite: Sprite2D = $Sprite2D
@onready var rect: Rect2i = sprite.get_region_rect()

func _ready() -> void:
	_setup(potion_type)


func _setup(type: Globals.PotionType) -> void:
	var rect_x: int = 0
	match type:
		Globals.PotionType.EMPTY:
			rect_x = 42
		Globals.PotionType.PUSHPULL:
			rect_x = 266
		Globals.PotionType.STRENGTH:
			rect_x = 74
	sprite.set_region_rect(Rect2i(rect_x, rect.position.y, rect.size.x, rect.size.y))
