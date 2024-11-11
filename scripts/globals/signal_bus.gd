extends Node

@warning_ignore("unused_signal") signal start_detecting_metals
@warning_ignore("unused_signal") signal stop_detecting_metals
@warning_ignore("unused_signal") signal start_pushing
@warning_ignore("unused_signal") signal start_pulling
@warning_ignore("unused_signal") signal stop_push_or_pulling
@warning_ignore("unused_signal") signal update_coin_ui(total_amount: int)
@warning_ignore("unused_signal") signal health_changed(health: int)
@warning_ignore("unused_signal") signal scarecrow_appear

@warning_ignore("unused_signal") signal potion_collected(potion: Potion)
@warning_ignore("unused_signal") signal potion_drank(type: Globals.PotionType, amount: float)
