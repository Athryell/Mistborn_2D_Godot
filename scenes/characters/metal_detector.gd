extends Area2D

const STARTING_LINES_AMOUNT = 2

var line_scene: PackedScene = load("res://scenes/characters/metal_line.tscn")
#var chest_point: Transform
#var detection_radius: float = 5.0

var is_pushing := false:
	set(value):
		is_pushing = value
		if is_pushing:
			SignalBus.start_pushing.emit()
		else:
			SignalBus.stop_push_or_pulling.emit()
var is_pulling := false:
	set(value):
		is_pulling = value
		if is_pulling:
			SignalBus.start_pulling.emit()
		else:
			SignalBus.stop_push_or_pulling.emit()
var is_detecting_metals := false:
	set(value):
		is_detecting_metals = value
		if value == true:
			SignalBus.start_detecting_metals.emit()
		else:
			SignalBus.stop_detecting_metals.emit()

var _lines_pool: Array[Line2D]
var _line_endpoint_dict: Dictionary # [Line2D, Rigidbody2D]
var _closest_line: Line2D

@onready var parent : RigidBody2D = get_parent()

func _ready():
	while _lines_pool.size() < STARTING_LINES_AMOUNT:
		_create_line()


func _process(_delta):
	if not is_detecting_metals:
		return
	
	var metals_in_range: Array = get_overlapping_bodies()

	if metals_in_range.size() == 0:
		_clear_lines()
		return

	#Get metal points
	var metal_objects: Array[RigidBody2D] = []
	for metal_obj in metals_in_range:
		#var children = metal_obj.get_children()
		#if metal_obj.get_node_or_null("MetalPoints"):
			#var points: Array = metal_obj.get_node("MetalPoints").get_children()
			#for p in points:
				#var child_position = metal_obj.position - p.position
				#var round_pos = Vector2i(child_position.x, child_position.y)
				#metal_points.append(child_position)
		#else:
		metal_objects.append(metal_obj)

	# Release unused lines
	if metal_objects.size() < _lines_pool.size():
		var points_to_remove = []
		for line in _line_endpoint_dict:
			if not metal_objects.has(_line_endpoint_dict[line]):
				points_to_remove.append(line)
		
		for line in points_to_remove:
			_release_line(line)
			_line_endpoint_dict.erase(line)
	
	# Add metal point to dictionary
	for rb in metal_objects:
		#TODO: round the positions
		if not _line_endpoint_dict.values().has(rb):
			var line = _get_line()
			_line_endpoint_dict[line] = rb

	_set_lines_positions()
	_select_closest_line_to_mouse()
	_highlight_line()


func _input(event):
	if event.is_action_pressed("use_metal"):
		is_detecting_metals = true
	elif event.is_action_released("use_metal"):
		is_detecting_metals = false
		_clear_lines()
	
	if event.is_action_pressed("toggle_metal"):
		if is_detecting_metals:
			is_detecting_metals = false
			_clear_lines()
		else:
			is_detecting_metals = true
		
		#if GameManager.instance.IsMetalDepleted():
			#stop_detect_metals()
			#return

		#GameManager.instance.DecrementIronSlider()
		
	if not _closest_line:
		return

	if event.is_action_pressed("pull_metal"):
		is_pulling = true
	elif event.is_action_pressed("push_metal"):
		is_pushing = true
	elif event.is_action_released("push_metal") or event.is_action_released("pull_metal"):
		is_pulling = false
		is_pushing = false


func _physics_process(_delta):
	if is_pulling or is_pushing:
		if not _line_endpoint_dict.has(_closest_line):
			return

		apply_force_to_metal(_line_endpoint_dict[_closest_line], is_pulling)


func apply_force_to_metal(metal_obj: RigidBody2D, pull: bool):
	if not metal_obj:
		return
	#var metal_obj = _line_endpoint_dict[_closest_line]
	var temp_metal_mass
	var force_direction = global_position - metal_obj.global_position
	var distance = force_direction.length()
	distance = clamp(distance, Globals.MAGNET_MIN_CLAMP, Globals.MAGNET_MAX_CLAMP)
	
	temp_metal_mass = metal_obj.mass
	if metal_obj.has_node("GroundCheck"):
		var obj_gc = metal_obj.get_node("GroundCheck")
		if obj_gc.is_grounded:
			if not pull and global_position.y < metal_obj.global_position.y or\
				pull and global_position.y > metal_obj.global_position.y:
				temp_metal_mass = 100
	
	var force_strength = (parent.mass * temp_metal_mass) / (distance * distance) * Globals.MAGNET_FORCE_MODIFIER
	
	if pull:
		_apply_force_to_bodies(-force_direction.normalized() * force_strength, metal_obj, temp_metal_mass)
	else:
		_apply_force_to_bodies(force_direction.normalized() * force_strength, metal_obj, temp_metal_mass)


func _apply_force_to_bodies(force_vector: Vector2, metal_obj: RigidBody2D, temp_metal_mass: float) -> void:
	parent.apply_central_force(force_vector)
	if temp_metal_mass < 100:
		metal_obj.apply_central_force(-force_vector)


func _select_closest_line_to_mouse():
	var min_angle_difference = INF

	var central_to_mouse: Vector2 = get_global_mouse_position() - global_position
	#var angle_to_mouse: float = rad_to_deg(atan2(central_to_mouse.y, central_to_mouse.x))
	
	for line in _line_endpoint_dict.keys():
		var end_point: Vector2 = line.get_point_position(1)
		var central_to_end: Vector2 = end_point - position
		#var angle_to_endpoint: float = rad_to_deg(atan2(central_to_end.y, central_to_end.x))
		var angle_diff: float = abs(central_to_mouse.angle_to(central_to_end))
	
		if angle_diff < min_angle_difference:
			min_angle_difference = angle_diff
			_closest_line = line


#func shoot(coin: RigidBody2D) -> void:
	#if not _line_endpoint_dict.values().has(coin):
		#var line = _get_line()
		#_line_endpoint_dict[line] = coin
		#_set_lines_positions()
		#_closest_line = line
		#_highlight_line()
		#is_pushing = true


func _highlight_line():
	for line in _line_endpoint_dict.keys():
		if line == _closest_line:
			line.default_color = Color.RED
		else:
			line.default_color = Color.BLUE


func _set_lines_positions():
	#TODO: Tween, lerp
	for line in _line_endpoint_dict:
		var value = _line_endpoint_dict[line]
		line.set_point_position(0, Vector2.ZERO)
		line.set_point_position(1, to_local(value.position))


func _clear_lines():
	for l in _line_endpoint_dict:
		_release_line(l)

	_line_endpoint_dict.clear()


func _create_line() -> Line2D:
	var new_line = line_scene.instantiate()
	add_child(new_line)
	_lines_pool.append(new_line)
	return new_line


func _get_line() -> Line2D:
	for line in _lines_pool:
		if not line.visible:
			line.visible = true
			return line
	
	var new_line = _create_line()
	new_line.visible = true
	return new_line


func _release_line(line):
	line.visible = false
