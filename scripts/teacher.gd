class_name Teacher
extends CharacterBody3D

@export var SPEED := 3.0
@export var STAND_OFFSET := 1.2
@export var ARRIVAL_DISTANCE := 0.4
@export var WAIT_AT_TABLE := 1.5

var _tables: Array[Table] = []
var _target_table: Table
var _waypoints: Array[Vector3] = []
var _wait_time := 0.0


func start_moving(tables: Array[Table]) -> void:
	_tables = tables
	_pick_next_table()


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if _wait_time > 0.0:
		_wait_time -= delta
		velocity.x = 0.0
		velocity.z = 0.0
		move_and_slide()
		if _wait_time <= 0.0:
			_pick_next_table()
		return

	if _waypoints.is_empty():
		velocity.x = 0.0
		velocity.z = 0.0
		move_and_slide()
		return

	var waypoint := _waypoints[0]
	var to_waypoint := waypoint - global_position
	to_waypoint.y = 0.0
	if to_waypoint.length() <= ARRIVAL_DISTANCE:
		_waypoints.remove_at(0)
		if _waypoints.is_empty():
			_arrive_at_table()
		velocity.x = 0.0
		velocity.z = 0.0
		move_and_slide()
		return

	var direction := to_waypoint.normalized()
	velocity.x = direction.x * SPEED
	velocity.z = direction.z * SPEED
	_face_direction(direction)
	move_and_slide()


func _pick_next_table() -> void:
	_waypoints.clear()
	if _tables.is_empty():
		return

	var table: Table = _tables.pick_random()
	if _tables.size() > 1:
		while table == _target_table:
			table = _tables.pick_random()

	if table == null or not is_instance_valid(table):
		return

	_target_table = table
	_waypoints = _aisle_path(_beside_table(table))


func _beside_table(table: Table) -> Vector3:
	var x_sign := 1.0 if randf() < 0.5 else -1.0
	var pos := table.global_position
	pos.x += x_sign * (table.WIDTH * 0.5 + STAND_OFFSET)
	pos.y = global_position.y
	# Stay in the side aisle or in front of the desk — never behind the student.
	if randf() < 0.5:
		pos.z = table.global_position.z
	else:
		pos.z = table.global_position.z - (table.LENGTH * 0.5 + STAND_OFFSET)
	return pos


func _aisle_path(dest: Vector3) -> Array[Vector3]:
	var path: Array[Vector3] = []
	var y := global_position.y
	dest.y = y

	var aisle_x := _nearest_aisle_x(global_position.x)
	var aisle_z := _nearest_aisle_z(global_position.z)
	var intersection := Vector3(aisle_x, y, aisle_z)

	if _xz_distance(global_position, intersection) > ARRIVAL_DISTANCE:
		var on_z_aisle := absf(global_position.z - aisle_z) <= ARRIVAL_DISTANCE
		if on_z_aisle:
			var via := Vector3(aisle_x, y, global_position.z)
			if _xz_distance(global_position, via) > ARRIVAL_DISTANCE:
				path.append(via)
		else:
			# Reach a Z-aisle along current X first so we don't cut across a student row.
			var via := Vector3(global_position.x, y, aisle_z)
			if _xz_distance(global_position, via) > ARRIVAL_DISTANCE:
				path.append(via)
		path.append(intersection)

	var along_row := Vector3(dest.x, y, aisle_z)
	if _xz_distance(intersection, along_row) > ARRIVAL_DISTANCE:
		path.append(along_row)

	if path.is_empty() or _xz_distance(path[path.size() - 1], dest) > ARRIVAL_DISTANCE:
		path.append(dest)

	return path


func _nearest_aisle_x(x: float) -> float:
	return _nearest_aisle(x, true)


func _nearest_aisle_z(z: float) -> float:
	return _nearest_aisle(z, false)


func _nearest_aisle(value: float, along_x: bool) -> float:
	var best := value
	var best_distance := INF
	for table in _tables:
		if table == null or not is_instance_valid(table):
			continue
		for candidate in _aisle_candidates(table, along_x):
			var distance := absf(candidate - value)
			if distance < best_distance:
				best_distance = distance
				best = candidate
	return best


func _aisle_candidates(table: Table, along_x: bool) -> Array[float]:
	var center := table.global_position.x if along_x else table.global_position.z
	var half := (table.WIDTH if along_x else table.LENGTH) * 0.5
	var plus := center + half + STAND_OFFSET
	var minus := center - half - STAND_OFFSET
	if not along_x:
		var seated := table.student
		plus = seated.global_position.z + seated.LENGTH * 0.5 + STAND_OFFSET
	return [plus, minus]


func _xz_distance(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x - b.x, a.z - b.z).length()


func _arrive_at_table() -> void:
	_wait_time = WAIT_AT_TABLE
	if is_instance_valid(_target_table):
		var look_pos := _target_table.global_position
		look_pos.y = global_position.y
		_face_direction(look_pos - global_position)


func _face_direction(direction: Vector3) -> void:
	direction.y = 0.0
	if direction.length_squared() < 0.0001:
		return
	look_at(global_position + direction, Vector3.UP)
