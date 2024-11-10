extends HBoxContainer

@onready var iron_pull: TextureRect = $IronPull
@onready var steel_push: TextureRect = $SteelPush
@onready var progress_bar_bg: NinePatchRect = $ProgressBar1/ProgressBar/ProgressBarBg

func _ready() -> void:
	SignalBus.start_detecting_metals.connect(_on_start_detecting)
	SignalBus.stop_detecting_metals.connect(_on_stop_detecting)
	SignalBus.start_pulling.connect(_on_start_pulling)
	SignalBus.start_pushing.connect(_on_start_pushing)
	SignalBus.stop_push_or_pulling.connect(_on_stop_pushpulling)


func _on_start_detecting() -> void:
	progress_bar_bg.material.set("shader_parameter/thickness", 1)


func _on_stop_detecting() -> void:
	progress_bar_bg.material.set("shader_parameter/thickness", 0)
	
func _on_start_pulling() -> void:
	iron_pull.material.set("shader_parameter/white_amount", 1)
	
func _on_start_pushing() -> void:
	steel_push.material.set("shader_parameter/white_amount", 1)

func _on_stop_pushpulling() -> void:
	iron_pull.material.set("shader_parameter/white_amount", 0)
	steel_push.material.set("shader_parameter/white_amount", 0)
