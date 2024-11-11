extends Node2D

const ARROWS_PULL = preload("res://assets/cursors/arrows_pull.png")
const ARROWS_PUSH = preload("res://assets/cursors/arrows_push.png")

var current_cursor: Sprite2D

@onready var cursor_bracket: Sprite2D = $CursorBracket
@onready var cursor_arrow: Sprite2D = $CursorArrows
@onready var player: Area2D = $"../Player/MetalDetector"

func _ready() -> void:
	SignalBus.start_pulling.connect(_on_pulling)
	SignalBus.start_pushing.connect(_on_pushing)
	SignalBus.stop_push_or_pulling.connect(_on_stop_psu_pul)
	SignalBus.start_detecting_metals.connect(_on_start_detecting_metals)
	SignalBus.stop_detecting_metals.connect(_on_stop_detecting_metals)


func _process(_delta: float) -> void:
	if current_cursor:
		current_cursor.global_position = get_global_mouse_position()
		current_cursor.look_at(player.global_position)


func _on_start_detecting_metals() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	_switch_cursor(cursor_bracket)
	current_cursor.show()


func _on_stop_detecting_metals() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if current_cursor:
		current_cursor.hide()


func _on_pushing() -> void:
	cursor_arrow.texture = ARROWS_PUSH
	_switch_cursor(cursor_arrow)
	
	

func _on_pulling() -> void:
	cursor_arrow.texture = ARROWS_PULL
	_switch_cursor(cursor_arrow)


func _on_stop_psu_pul() -> void:
	_switch_cursor(cursor_bracket)


func _switch_cursor(new_cursor: Sprite2D) -> void:
	if current_cursor:
		current_cursor.hide()
	current_cursor = new_cursor
	new_cursor.show()
