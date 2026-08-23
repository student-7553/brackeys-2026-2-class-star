class_name TeacherVision
extends Node3D

signal player_spotted(player: Node3D)

@export var vision_range := 8.0
@export var vision_fov := 60.0
@export var eye_height := 1.4
@export var cone_color := Color(1.0, 0.12, 0.1, 0.28)

var player: Node3D
var game_manager: GameManager

var _has_spotted := false
var _cone: MeshInstance3D


func _ready() -> void:
	_build_cone()


func setup(watched_player: Node3D, manager: GameManager) -> void:
	player = watched_player
	game_manager = manager
	_has_spotted = false


func _physics_process(_delta: float) -> void:
	if _has_spotted:
		return
	if player == null or not is_instance_valid(player):
		return
	if not _is_player_in_cone():
		return
	if not _has_line_of_sight():
		return

	_has_spotted = true
	player_spotted.emit(player)
	if game_manager != null:
		game_manager.on_player_spotted()


func _is_player_in_cone() -> bool:
	var origin := _eye_position()
	var to_player := _player_aim_point() - origin
	var distance := to_player.length()
	if distance > vision_range or distance < 0.001:
		return false

	var forward := -global_transform.basis.z
	return forward.angle_to(to_player) <= deg_to_rad(vision_fov * 0.5)


func _has_line_of_sight() -> bool:
	var space := get_world_3d().direct_space_state
	var origin := _eye_position() + (-global_transform.basis.z) * 0.25
	var query := PhysicsRayQueryParameters3D.create(origin, _player_aim_point())
	var teacher := get_parent()
	if teacher is CollisionObject3D:
		query.exclude = [teacher.get_rid()]

	var hit := space.intersect_ray(query)
	if hit.is_empty():
		return true
	return hit.collider == player


func _eye_position() -> Vector3:
	return global_position + Vector3.UP * eye_height


func _player_aim_point() -> Vector3:
	return player.global_position + Vector3.UP * 0.9


func _build_cone() -> void:
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.01
	mesh.bottom_radius = vision_range * tan(deg_to_rad(vision_fov * 0.5))
	mesh.height = vision_range
	mesh.radial_segments = 24

	var material := StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = cone_color
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.no_depth_test = false
	mesh.material = material

	_cone = MeshInstance3D.new()
	_cone.mesh = mesh
	_cone.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_cone.rotation_degrees = Vector3(90.0, 0.0, 0.0)
	_cone.position = Vector3(0.0, eye_height, -vision_range * 0.5)
	add_child(_cone)
