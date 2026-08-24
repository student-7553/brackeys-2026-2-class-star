class_name PlayerPaperFullscreen
extends CanvasLayer


func _ready() -> void:
	hide()


func show_paper() -> void:
	show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if InputManager.instance != null:
		InputManager.instance.movement_enabled = false


func hide_paper() -> void:
	hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if InputManager.instance != null:
		InputManager.instance.movement_enabled = true


func is_open() -> bool:
	return visible
