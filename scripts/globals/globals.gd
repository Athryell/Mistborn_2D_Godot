extends Node

const MAGNET_FORCE_MODIFIER: float = 20000
const MAGNET_MIN_CLAMP: float = 5.0 # 0-30 -> Lower value for a stronger initial push
const MAGNET_MAX_CLAMP: float = 30.0 # 0-50 -> lower values pushes A LOT further, higher value pushes less
