extends CenterContainer

@onready var health_bar_bottom: ProgressBar = $HealthBarBottom
@onready var health_bar_top: ProgressBar = $HealthBarTop
@onready var wait_time: Timer = $WaitTimeBottomBar

var current_health: int

func _ready() -> void:
	SignalBus.health_changed.connect(_update_health_bars)
	health_bar_bottom.max_value = Globals.STARTING_PLAYER_HEALTH
	health_bar_top.max_value = Globals.STARTING_PLAYER_HEALTH
	health_bar_bottom.value = Globals.STARTING_PLAYER_HEALTH
	health_bar_top.value = Globals.STARTING_PLAYER_HEALTH


func _update_health_bars(health: int) -> void:
	wait_time.start()
	current_health = health
	_update_bar(health_bar_top, current_health, 0.1)


func _on_wait_time_bottom_bar_timeout() -> void:
	_update_bar(health_bar_bottom, current_health, 0.3)


func _update_bar(bar: ProgressBar, health: int, speed: float) -> void:
	var tween = create_tween()
	tween.tween_property(bar, "value", health, speed)
