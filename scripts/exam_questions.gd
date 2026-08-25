class_name ExamQuestions
extends Resource

const JSON_PATH := "res://questions/exam_questions.json"

# Currently has the following fields
# "prompt": 
# "options":
# "correct_option_id":
@export var selected_questions: Array[Dictionary] = []

var _question_bank: Dictionary = {}


func load_from_json(path: String = JSON_PATH) -> void:
	_question_bank.clear()
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Could not open exam questions at %s" % path)
		return

	var data: Variant = JSON.parse_string(file.get_as_text())
	if typeof(data) != TYPE_DICTIONARY:
		push_error("Exam questions file is not a JSON object")
		return

	_question_bank = data


func pick_random(count: int) -> void:
	selected_questions.clear()
	var pool: Array[Dictionary] = []
	for questions: Variant in _question_bank.values():
		if typeof(questions) != TYPE_ARRAY:
			continue
		for question: Variant in questions:
			if typeof(question) != TYPE_DICTIONARY:
				continue
			var source := question as Dictionary
			pool.append({
				"prompt": source.get("prompt", ""),
				"options": source.get("options", []),
				"correct_option_id": source.get("correct_option_id", ""),
			})

	pool.shuffle()
	var pick_count := mini(count, pool.size())
	for i in pick_count:
		selected_questions.append(pool[i])
