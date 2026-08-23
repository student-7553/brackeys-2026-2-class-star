class_name GameManager
extends Node

signal player_spawned(player: CharacterBody3D)
signal game_started
signal game_stopped

const PLAYER_SCENE := preload("res://scenes/player.tscn")
const TABLE_SCENE := preload("res://scenes/table.tscn")
const SPAWN_POSITION := Vector3.ZERO
const TABLE_GRID_SIZE := 4
const TABLE_SPACING := 4.0

var player: CharacterBody3D
var tables: Array[Table] = []
var elapsed_time := 0.0
var is_running := false

var _timer: Timer
var _time_label: Label


func _ready() -> void:
	_setup_hud()
	_setup_timer()
	start_game()


func start_game() -> void:
	elapsed_time = 0.0
	is_running = true
	_spawn_player()
	_spawn_tables()
	_timer.start()
	_update_time_label()
	game_started.emit()


func stop_game() -> void:
	is_running = false
	_timer.stop()
	game_stopped.emit()


func _spawn_player() -> void:
	if player != null and is_instance_valid(player):
		player.queue_free()

	player = PLAYER_SCENE.instantiate() as CharacterBody3D
	player.position = SPAWN_POSITION
	add_child(player)
	player_spawned.emit(player)


func _spawn_tables() -> void:
	_clear_tables()
	var origin := (TABLE_GRID_SIZE - 1) * TABLE_SPACING * 0.5
	for x in TABLE_GRID_SIZE:
		for z in TABLE_GRID_SIZE:
			var table := TABLE_SCENE.instantiate() as Table
			table.position = Vector3(
				x * TABLE_SPACING - origin,
				0.0,
				z * TABLE_SPACING - origin
			)
			add_child(table)
			tables.append(table)


func _clear_tables() -> void:
	for table in tables:
		if is_instance_valid(table):
			table.queue_free()
	tables.clear()


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
	elapsed_time += delta
	_update_time_label()


func _update_time_label() -> void:
	var minutes := int(elapsed_time / 60.0)
	var seconds := fmod(elapsed_time, 60.0)
	_time_label.text = "Time  %02d:%05.2f" % [minutes, seconds]
