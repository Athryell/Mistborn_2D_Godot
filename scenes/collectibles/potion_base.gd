@tool
extends RigidBody2D

enum Type {EMPTY, PUSHPULL, STRENGTH}

@export var potion_type : Type = Type.EMPTY:
	set(value):
		potion_type = value
		if sprite:
			_setup(value)

@onready var sprite: Sprite2D = $Sprite2D
@onready var rect: Rect2i = sprite.get_region_rect()

func _ready() -> void:
	_setup(potion_type)


func _setup(type: Type) -> void:
	var rect_x: int = 0
	match type:
		Type.EMPTY:
			rect_x = 42
		Type.PUSHPULL:
			rect_x = 266
		Type.STRENGTH:
			rect_x = 74
	sprite.set_region_rect(Rect2i(rect_x, rect.position.y, rect.size.x, rect.size.y))
