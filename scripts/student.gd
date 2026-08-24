@tool
class_name Student
extends StaticBody3D

@export var WIDTH := 0.6:
	set(value):
		WIDTH = maxf(value, 0.01)
		_apply_size()

@export var HEIGHT := 1.1:
	set(value):
		HEIGHT = maxf(value, 0.01)
		_apply_size()

@export var LENGTH := 0.45:
	set(value):
		LENGTH = maxf(value, 0.01)
		_apply_size()

@onready var _mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var _collision_shape: CollisionShape3D = $CollisionShape3D


func _ready() -> void:
	_apply_size()


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
