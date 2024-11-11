extends Area2D

enum Keys {W, A, S, D, TAB, ALT, SPACE, MOUSE_RIGHT_BTN, MOUSE_LEFT_BTN}

@export var _key : Keys

@onready var _sign: Sprite2D = $SpriteClip/SpriteSign
@onready var _key_sprite: Sprite2D = $SpriteClip/SpriteSign/SpriteKey

func _ready() -> void:
	_sign.position.y = 1
	match _key:
		Keys.A:
			_key_sprite.texture = preload("res://assets/sprites/ui/keyboard/T_A_Key_Alt.png")
		Keys.D:
			_key_sprite.texture = preload("res://assets/sprites/ui/keyboard/T_D_Key_Alt.png")
		Keys.TAB:
			_key_sprite.texture = preload("res://assets/sprites/ui/keyboard/T_Tab_Key_Alt.png")
			_key_sprite.set_flip_v(true)
		Keys.ALT:
			_key_sprite.texture = preload("res://assets/sprites/ui/keyboard/T_Alt_Key_Alt.png")
		Keys.SPACE:
			_key_sprite.texture = preload("res://assets/sprites/ui/keyboard/T_Space_Key_Alt.png")
		Keys.MOUSE_RIGHT_BTN:
			_key_sprite.texture = preload("res://assets/sprites/ui/keyboard/T_Mouse_Right_Key_Alt.png")
		Keys.MOUSE_LEFT_BTN:
			_key_sprite.texture = preload("res://assets/sprites/ui/keyboard/T_Mouse_Left_Key_Alt.png")


func _on_body_entered(_body: Node2D) -> void:
		var tween = create_tween()
		tween.tween_property(_sign, "position:y", 0, 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
