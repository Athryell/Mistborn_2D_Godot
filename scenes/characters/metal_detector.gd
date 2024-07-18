extends Area2D

const STARTING_LINES_AMOUNT = 2

var line_scene: PackedScene = load("res://scenes/characters/metal_line.tscn")
#var chestPoint: Transform
#var detectionRadius: float = 5.0
#var magnetForceModifier: float = 1.0
#var magnetMinClamp: float = 3.0
#var magnetMaxClamp: float = 15.0
#
var _is_pushing := false
var _is_pulling := false
var _is_detecting_metals := false
#
var _lines_pool: Array[Line2D]
var _line_endpoint_dict: Dictionary # [Line2D, Vector2 -> Rigidbody2D]
var _closest_line: Line2D


func _ready():
	while _lines_pool.size() < STARTING_LINES_AMOUNT:
		_create_line()


func _process(delta):
	if not _is_detecting_metals:
		return
	
	var metals_in_range: Array = get_overlapping_bodies()

	if metals_in_range.size() == 0:
		_clear_lines()
		return

	#Get metal points
	var metal_points: Array[Vector2] = []
	for metal_obj in metals_in_range:
		var children = metal_obj.get_children()
		if metal_obj.get_node_or_null("MetalPoints"):
			var points: Array = metal_obj.get_node("MetalPoints").get_children()
			for p in points:
				var child_position = metal_obj.position - p.position
				var round_pos = Vector2i(child_position.x, child_position.y)
				metal_points.append(child_position)
		else:
			metal_points.append(metal_obj.position)

	# Release unused lines
	if metal_points.size() < _lines_pool.size():
		var points_to_remove = []
		for line in _line_endpoint_dict:
			if not metal_points.has(_line_endpoint_dict[line]):
				points_to_remove.append(line)
		
		for line in points_to_remove:
			_release_line(line)
			_line_endpoint_dict.erase(line)
	
	# Add metal point to dictionary
	for point in metal_points:
		#TODO: round the positions
		if not _line_endpoint_dict.values().has(point):
			var line = _get_line()
			_line_endpoint_dict[line] = point
#
	_set_lines_positions()
	_select_closest_line_to_mouse()

func _input(event):
	if event.is_action_pressed("toggle_metal"):
		
		if _is_detecting_metals:
			_is_detecting_metals = false
			_clear_lines()
		else:
			_is_detecting_metals = true
		
		#if GameManager.instance.IsMetalDepleted():
			#stop_detect_metals()
			#return

		#GameManager.instance.DecrementIronSlider()
		
	if not _closest_line:
		return

	if event.is_action_pressed("left_click"):
		_is_pulling = true
	elif event.is_action_pressed("right_click"):
		_is_pushing = true
	elif event.is_action_released("left_click") or event.is_action_released("right_click"):
		_is_pulling = false
		_is_pushing = false


func _physics_process(delta):
	pass
	if _is_pulling or _is_pushing:
		_apply_force_to_metal()
#
func _apply_force_to_metal():
	if not _line_endpoint_dict.has(_closest_line):
		return

	var point_offset: Vector2 = _line_endpoint_dict[_closest_line].global_position
	var metal_obj = _line_endpoint_dict[_closest_line].get_parent().get_node("RigidBody2D")
	#var forceDirection = global_position - metalObjRb.global_position
	#var distance = forceDirection.length()

	#distance = clamp(distance, magnetMinClamp, magnetMaxClamp)

	#var forceStrength

	#if metalObjRb.mass < 100:
		#forceStrength = (physics_process_vars.step * metalObjRb.mass) / (distance * distance) * magnetForceModifier
	#else:
		#forceStrength = (physics_process_vars.step) / (distance * distance) * magnetForceModifier

	#if _isPulling:
		#apply_central_impulse(-forceDirection.normalized() * forceStrength)
		#metalObjRb.apply_central_impulse(forceDirection.normalized() * forceStrength, metalObjRb.to_local(pointOffset))
	#elif _isPushing:
		#apply_central_impulse(forceDirection.normalized() * forceStrength)
		#metalObjRb.apply_central_impulse(-forceDirection.normalized() * forceStrength, metalObjRb.to_local(pointOffset))

func _select_closest_line_to_mouse():
	var min_angle_difference = INF

	var central_to_mouse: Vector2 = get_global_mouse_position() - global_position
	#var angle_to_mouse: float = rad_to_deg(atan2(central_to_mouse.y, central_to_mouse.x))
	
	for line in _line_endpoint_dict.keys():
		var end_point: Vector2 = line.get_point_position(1)
		var central_to_end: Vector2 = end_point - position
		#var angle_to_endpoint: float = rad_to_deg(atan2(central_to_end.y, central_to_end.x))
		var angle_difference: float = abs(central_to_mouse.angle_to(central_to_end))
	
		if angle_difference < min_angle_difference:
			min_angle_difference = angle_difference
			_closest_line = line

	_highlight_line()
#
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
		line.set_point_position(1, to_local(value))


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
