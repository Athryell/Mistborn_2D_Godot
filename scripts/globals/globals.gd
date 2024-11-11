extends Node

enum PotionType {EMPTY, PUSHPULL, STRENGTH}

const MAGNET_FORCE_MODIFIER: float = 20000
const MAGNET_MIN_CLAMP: float = 10.0 # 0-30 -> Lower value for a stronger initial push
const MAGNET_MAX_CLAMP: float = 30.0 # 0-50 -> lower values pushes A LOT further, higher value pushes less


#region Player
const STARTING_PLAYER_HEALTH := 10
const MAX_PORTION_STORED := 3

const MAX_PUSHPULL_STORED := 100
var pushpull_left: float = 0.0
#endregion

func _ready() -> void:
	SignalBus.potion_drank.connect(_restore_use)


func _restore_use(type, amount) -> void:
	match type:
		Globals.PotionType.PUSHPULL:
			pushpull_left = min(pushpull_left + amount, MAX_PUSHPULL_STORED)
