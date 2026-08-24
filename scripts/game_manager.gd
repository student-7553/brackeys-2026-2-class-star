class_name GameManager
extends Node

signal player_spawned(player: CharacterBody3D)
signal teacher_spawned(teacher: Teacher)
signal game_started
signal game_stopped

const PLAYER_SCENE := preload("res://scenes/player.tscn")
const TEACHER_SCENE := preload("res://scenes/teacher.tscn")
const STUDENT_SCENE := preload("res://scenes/student.tscn")
const EXAM_QUESTIONS_PATH := "res://questions/exam_questions.json"

@export var const_data: ConstData

var player: Player
var teacher: Teacher
var students: Array[Student] = []
var exam_questions: Dictionary = {}
var selected_questions: Array[Dictionary] = []
var elapsed_time := 0.0
var is_running := false

var _timer: Timer
var _time_label: Label


func _ready() -> void:
	_load_exam_questions()
	_setup_hud()
	_setup_timer()
	start_game()


func start_game() -> void:
	elapsed_time = const_data.COUNTDOWN
	is_running = true
	_pick_questions()
	_spawn_classroom()
	_spawn_teacher()
	_timer.start()
	_update_time_label()
	game_started.emit()


func stop_game() -> void:
	is_running = false
	_timer.stop()
	game_stopped.emit()


func player_spotted(_spotted_player: Node3D) -> void:
	if not is_running:
		return
	stop_game()
	if teacher != null and is_instance_valid(teacher):
		teacher.set_physics_process(false)
	_time_label.text = "SPOTTED!"
	_time_label.add_theme_color_override("font_color", Color(1.0, 0.25, 0.2))


func _spawn_classroom() -> void:
	_clear_students()
	_clear_player()

	var grid_size := const_data.TABLE_GRID_SIZE
	var origin := (grid_size - 1) * const_data.TABLE_SPACING * 0.5
	var player_x := randi_range(0, grid_size - 1)
	var player_z := randi_range(0, grid_size - 1)

	for x in grid_size:
		for z in grid_size:
			var seat := Vector3(
				x * const_data.TABLE_SPACING - origin,
				0.0,
				z * const_data.TABLE_SPACING - origin
			)
			if x == player_x and z == player_z:
				_spawn_player_at(seat)
			else:
				_spawn_student_at(seat)


func _spawn_player_at(seat: Vector3) -> void:
	player = PLAYER_SCENE.instantiate() as Player
	player.const_data = const_data
	player.position = seat
	add_child(player)
	player_spawned.emit(player)


func _spawn_student_at(seat: Vector3) -> void:
	var student := STUDENT_SCENE.instantiate() as Student
	student.WIDTH = const_data.STUDENT_WIDTH
	student.HEIGHT = const_data.STUDENT_HEIGHT
	student.LENGTH = const_data.STUDENT_LENGTH
	student.const_data = const_data
	student.position = seat
	add_child(student)
	students.append(student)


func _spawn_teacher() -> void:
	if teacher != null and is_instance_valid(teacher):
		teacher.queue_free()

	teacher = TEACHER_SCENE.instantiate() as Teacher
	teacher.position = const_data.TEACHER_SPAWN_POSITION
	add_child(teacher)
	teacher.start_moving(students)
	var vision := teacher.get_node("TeacherVision") as TeacherVision
	if vision != null:
		vision.setup_vision(player)
		vision.player_spotted.connect(player_spotted)
	teacher_spawned.emit(teacher)


func _clear_students() -> void:
	for student in students:
		if is_instance_valid(student):
			student.queue_free()
	students.clear()


func _clear_player() -> void:
	if player != null and is_instance_valid(player):
		player.queue_free()
	player = null


func _load_exam_questions() -> void:
	exam_questions.clear()
	var file := FileAccess.open(EXAM_QUESTIONS_PATH, FileAccess.READ)
	if file == null:
		push_error("Could not open exam questions at %s" % EXAM_QUESTIONS_PATH)
		return

	var data: Variant = JSON.parse_string(file.get_as_text())
	if typeof(data) != TYPE_DICTIONARY:
		push_error("Exam questions file is not a JSON object")
		return

	exam_questions = data


func _pick_questions() -> void:
	selected_questions.clear()
	var pool: Array[Dictionary] = []
	for questions: Variant in exam_questions.values():
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
	var count := mini(const_data.QUESTION_COUNT, pool.size())
	for i in count:
		selected_questions.append(pool[i])


func _setup_timer() -> void:
	_timer = Timer.new()
	_timer.wait_time = 1.0
	_timer.one_shot = false
	_timer.autostart = false
	add_child(_timer)


func _setup_hud() -> void:
	var hud := CanvasLayer.new()
	add_child(hud)

	_time_label = Label.new()
	_time_label.position = Vector2(24, 20)
	_time_label.add_theme_font_size_override("font_size", 28)
	_time_label.add_theme_color_override("font_color", Color.WHITE)
	_time_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	_time_label.add_theme_constant_override("outline_size", 6)
	hud.add_child(_time_label)


func _process(delta: float) -> void:
	if not is_running:
		return
	elapsed_time = maxf(elapsed_time - delta, 0.0)
	_update_time_label()
	if elapsed_time <= 0.0:
		stop_game()


func _update_time_label() -> void:
	var minutes := int(elapsed_time / 60.0)
	var seconds := fmod(elapsed_time, 60.0)
	_time_label.text = "Time  %02d:%05.2f" % [minutes, seconds]
