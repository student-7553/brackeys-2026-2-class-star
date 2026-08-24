@tool
class_name Student
extends StaticBody3D

const TABLE_SCENE := preload("res://scenes/table.tscn")
const PAPER_SCENE := preload("res://scenes/student_paper.tscn")

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

var table: Table
var paper: StudentPaper
var const_data: ConstData

@onready var _mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var _collision_shape: CollisionShape3D = $CollisionShape3D


func _ready() -> void:
	_apply_size()
	if Engine.is_editor_hint():
		return
	_spawn_table()
	_spawn_paper()


func _spawn_table() -> void:
	if table != null and is_instance_valid(table):
		table.queue_free()

	var table_width := 1.5
	var table_height := 0.75
	var table_length := 1.5
	var gap := 0.25
	if const_data != null:
		table_width = const_data.TABLE_WIDTH
		table_height = const_data.TABLE_HEIGHT
		table_length = const_data.TABLE_LENGTH
		gap = const_data.STUDENT_TABLE_GAP

	table = TABLE_SCENE.instantiate() as Table
	table.WIDTH = table_width
	table.HEIGHT = table_height
	table.LENGTH = table_length
	table.position = Vector3(0.0, 0.0, - (LENGTH * 0.5 + table_length * 0.5 + gap))
	add_child(table)


func _spawn_paper() -> void:
	if paper != null and is_instance_valid(paper):
		paper.queue_free()
	if table == null or const_data == null:
		return

	paper = PAPER_SCENE.instantiate() as StudentPaper
	paper.WIDTH = const_data.PAPER_WIDTH
	paper.HEIGHT = const_data.PAPER_HEIGHT
	paper.LENGTH = const_data.PAPER_LENGTH
	paper.position = Vector3(table.position.x, table.HEIGHT, table.position.z)
	add_child(paper)


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
