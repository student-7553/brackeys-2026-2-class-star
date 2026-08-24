class_name InputManager
extends Node

signal look_delta(relative: Vector2)
signal interact_pressed

static var instance: InputManager


func _enter_tree() -> void:
	instance = self


func _exit_tree() -> void:
	if instance == self:
		instance = null


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func get_move_vector() -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_forward", "move_back")


func is_jump_just_pressed() -> bool:
	return Input.is_action_just_pressed("jump")


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		look_delta.emit(event.relative)
		return

	if event.is_action_pressed("ui_cancel"):
		_toggle_mouse_capture()
		return

	if event.is_action_pressed("interact"):
		interact_pressed.emit()


func _toggle_mouse_capture() -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
