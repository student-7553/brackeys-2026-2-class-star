@tool
class_name PlayerPaper
extends StaticBody3D

const FULLSCREEN_SCENE := preload("res://scenes/player_paper_fullscreen.tscn")

@export var WIDTH := 0.21:
	set(value):
		WIDTH = maxf(value, 0.01)
		_apply_size()

@export var HEIGHT := 0.008:
	set(value):
		HEIGHT = maxf(value, 0.001)
		_apply_size()

@export var LENGTH := 0.297:
	set(value):
		LENGTH = maxf(value, 0.01)
		_apply_size()

var fullscreen: PlayerPaperFullscreen

@onready var _mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var _collision_shape: CollisionShape3D = $CollisionShape3D


func _ready() -> void:
	_apply_size()
	if Engine.is_editor_hint():
		return
	_spawn_fullscreen()
	if InputManager.instance == null:
		return
	if not InputManager.instance.interact_pressed.is_connected(_on_interact_pressed):
		InputManager.instance.interact_pressed.connect(_on_interact_pressed)


func _spawn_fullscreen() -> void:
	if fullscreen != null and is_instance_valid(fullscreen):
		fullscreen.queue_free()
	fullscreen = FULLSCREEN_SCENE.instantiate() as PlayerPaperFullscreen
	add_child(fullscreen)
	fullscreen.hide_paper()


func _on_interact_pressed() -> void:
	if fullscreen == null:
		return
	if fullscreen.is_open():
		fullscreen.hide_paper()
		return
	if not _is_player_close():
		return
	fullscreen.show_paper()


func _is_player_close() -> bool:
	var player := get_parent() as Player
	if player == null:
		return false
	var max_distance := 2.0
	if player.const_data != null:
		max_distance = player.const_data.PAPER_INTERACT_DISTANCE
	var delta := player.global_position - global_position
	delta.y = 0.0
	return delta.length() <= max_distance


func _apply_size() -> void:
	if not is_node_ready():
		return

	var size := Vector3(WIDTH, HEIGHT, LENGTH)
	var mesh := _mesh_instance.mesh as BoxMesh
	if mesh != null:
		mesh.size = size
	var shape := _collision_shape.shape as BoxShape3D
	if shape != null:
		shape.size = size

	var offset := Vector3(0.0, HEIGHT * 0.5, 0.0)
	_mesh_instance.position = offset
	_collision_shape.position = offset
