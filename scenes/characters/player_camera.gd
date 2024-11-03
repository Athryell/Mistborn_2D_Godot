extends Camera2D

@export var tween_duration := 1

var starting_offset := Vector2(0, -80)
var airborn_offset := Vector2(0, -20)
var starting_zoom := Vector2(1.5, 1.5)
var airborne_zoom := Vector2(1, 1)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_zoom(starting_zoom)
	set_offset(starting_offset)
	SignalBus.start_detecting_metals.connect(_zoom_out)
	SignalBus.stop_detecting_metals.connect(_zoom_in)


func _zoom_out() -> void:
	var tween = create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "zoom", airborne_zoom, tween_duration)
	tween.tween_property(self, "offset", airborn_offset, tween_duration)
	
func _zoom_in() -> void:
	var tween = create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "zoom", starting_zoom, tween_duration)
	tween.tween_property(self, "offset", starting_offset, tween_duration)
