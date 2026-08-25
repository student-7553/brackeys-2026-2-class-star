class_name Player
extends CharacterBody3D

const TABLE_SCENE := preload("res://scenes/table.tscn")
const PAPER_SCENE := preload("res://scenes/player_paper.tscn")

@export var SPEED := 5.0
@export var JUMP_VELOCITY := 4.5
@export var MOUSE_SENSITIVITY := 0.002

var table: Table
var paper: PlayerPaper
var const_data: ConstData

var _move_input := Vector2.ZERO
var _jump_requested := false

@onready var camera: Camera3D = $Camera3D


func _ready() -> void:
	InputManager.instance.look_delta.connect(_on_look_delta)
	InputManager.instance.move_vector.connect(_on_move_vector)
	InputManager.instance.jump_pressed.connect(_on_jump_pressed)
	_spawn_table()
	_spawn_paper()


func _spawn_table() -> void:
	if table != null and is_instance_valid(table):
		table.queue_free()
	if const_data == null:
		return

	table = TABLE_SCENE.instantiate() as Table
	table.WIDTH = const_data.TABLE_WIDTH
	table.HEIGHT = const_data.TABLE_HEIGHT
	table.LENGTH = const_data.TABLE_LENGTH
	table.position = Vector3(
		0.0,
		0.0,
		- (const_data.STUDENT_LENGTH * 0.5 + const_data.TABLE_LENGTH * 0.5 + const_data.STUDENT_TABLE_GAP)
	)
	add_child(table)


func _spawn_paper() -> void:
	if paper != null and is_instance_valid(paper):
		paper.queue_free()
	if table == null or const_data == null:
		return

	paper = PAPER_SCENE.instantiate() as PlayerPaper
	paper.WIDTH = const_data.PAPER_WIDTH
	paper.HEIGHT = const_data.PAPER_HEIGHT
	paper.LENGTH = const_data.PAPER_LENGTH
	paper.position = Vector3(table.position.x, table.HEIGHT, table.position.z)
	add_child(paper)
	# Keep the desk in world space so it does not follow the player.
	table.top_level = true
	paper.top_level = true


func _on_look_delta(relative: Vector2) -> void:
	rotate_y(-relative.x * MOUSE_SENSITIVITY)
	camera.rotate_x(-relative.y * MOUSE_SENSITIVITY)
	camera.rotation.x = clampf(camera.rotation.x, deg_to_rad(-89.0), deg_to_rad(89.0))


func _on_move_vector(vector: Vector2) -> void:
	_move_input = vector


func _on_jump_pressed() -> void:
	_jump_requested = true


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if _jump_requested and is_on_floor():
		velocity.y = JUMP_VELOCITY
	_jump_requested = false

	var direction := (transform.basis * Vector3(_move_input.x, 0.0, _move_input.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED)
		velocity.z = move_toward(velocity.z, 0.0, SPEED)

	move_and_slide()
