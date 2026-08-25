class_name PlayerPaperFullscreen
extends CanvasLayer

@export var exam_questions: ExamQuestions

@onready var _prompt_label: Label = $Center/Paper/MarginContainer/ScrollContainer/PromptLabel


func _ready() -> void:
	_refresh_question()
	hide()


func show_paper() -> void:
	_refresh_question()
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


func _refresh_question() -> void:
	if exam_questions == null or exam_questions.selected_questions.is_empty():
		_prompt_label.text = ""
		return

	var lines: PackedStringArray = []
	for i in exam_questions.selected_questions.size():
		var question: Dictionary = exam_questions.selected_questions[i]
		var prompt := str(question.get("prompt", ""))
		lines.append("%d. %s" % [i + 1, prompt])

		var options: Variant = question.get("options", [])
		if typeof(options) == TYPE_ARRAY:
			for option: Variant in options:
				if typeof(option) != TYPE_DICTIONARY:
					continue
				var option_data := option as Dictionary
				var option_id := str(option_data.get("id", ""))
				var option_text := str(option_data.get("text", ""))
				lines.append("   %s) %s" % [option_id, option_text])

	_prompt_label.text = "\n\n".join(lines)
