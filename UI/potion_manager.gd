extends Node2D

const EMPTY_POTION = preload("res://UI/empty_potion_ui.tscn")
var _potions_held: Dictionary #{potion_ui, [Globals.PotionType, fill_amount]}
var _dict_keys

func _ready() -> void:
	SignalBus.potion_collected.connect(_on_potion_collected)
	for i in Globals.MAX_PORTION_STORED:
		var new_potion = EMPTY_POTION.instantiate()
		add_child(new_potion)
		new_potion.name = "Potion" + str(i + 1)
		new_potion.global_position = Vector2(global_position.x + (i * 16), global_position.y)
		var input_sprite = load("res://assets/sprites/ui/keyboard/T_" + str(i + 1) + "_Key_Alt.png")
		new_potion.get_node("Input").texture = input_sprite
		_potions_held[new_potion] = [Globals.PotionType.EMPTY, 0]
	_dict_keys = _potions_held.keys()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("potion_1"):
		var p = get_node("Potion1")
		if _potions_held[p][0] != Globals.PotionType.EMPTY:
			_drink_potion(p)
	if Input.is_action_just_pressed("potion_2"):
		var p = get_node("Potion2")
		if _potions_held[p][0] != Globals.PotionType.EMPTY:
			_drink_potion(p)
	if Input.is_action_just_pressed("potion_3"):
		var p = get_node("Potion3")
		if _potions_held[p][0] != Globals.PotionType.EMPTY:
			_drink_potion(p)


func _drink_potion(pot_ui : Sprite2D) -> void:
	SignalBus.potion_drank.emit(_potions_held[pot_ui][0], _potions_held[pot_ui][1])
	pot_ui.get_node("AnimationPlayer").play_backwards("potion_fill")
	_potions_held[pot_ui][0] = Globals.PotionType.EMPTY
	_potions_held[pot_ui][1] = 0


func _on_potion_collected(potion: Potion) -> void:
	for potion_ui in _potions_held:
		if _potions_held[potion_ui][0] != Globals.PotionType.EMPTY:
			continue
		_potions_held[potion_ui][0] = potion.potion_type
		_potions_held[potion_ui][1] = potion.fill_amount
		var sprites = potion_ui.get_node("PotionSprites")
		for s in sprites.get_children():
			s.hide()
		match potion.potion_type:
			Globals.PotionType.PUSHPULL:
				sprites.get_node("PotionBlue").show()
			Globals.PotionType.STRENGTH:
				sprites.get_node("PotionRed").show()
		potion_ui.get_node("AnimationPlayer").play("potion_fill")
		return
		
