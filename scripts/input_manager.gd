class_name InputManager
extends Node

signal look_delta(relative: Vector2)
signal interact_pressed
signal jump_pressed
signal move_vector(vector: Vector2)

static var instance: InputManager

var movement_enabled := true


func _enter_tree() -> void:
	instance = self


func _exit_tree() -> void:
	if instance == self:
		instance = null


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(_delta: float) -> void:
	if not movement_enabled:
		move_vector.emit(Vector2.ZERO)
		return
	move_vector.emit(Input.get_vector("move_left", "move_right", "move_forward", "move_back"))


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		look_delta.emit(event.relative)
		return

	if event.is_action_pressed("ui_cancel"):
		_toggle_mouse_capture()
		return

	if event.is_action_pressed("interact"):
		interact_pressed.emit()
		return

	if event.is_action_pressed("jump") and movement_enabled:
		jump_pressed.emit()


func _toggle_mouse_capture() -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
