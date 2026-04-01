extends Node


#ДЛЯ НАСТРОЕК МУЗЫКИ
const AUDIO_OFF_DB := -80.0
const AUDIO_ON_DB := 0.0

var music_bus := AudioServer.get_bus_index("Music")
var sound_bus := AudioServer.get_bus_index("Sound")


var settings_return_scene_path: String = "res://scenes/main_menu.tscn"


func set_music_enabled(enabled: bool) -> void:
	if enabled:
		AudioServer.set_bus_volume_db(music_bus, AUDIO_ON_DB)
	else:
		AudioServer.set_bus_volume_db(music_bus, AUDIO_OFF_DB)

func set_sound_enabled(enabled: bool) -> void:
	if enabled:
		AudioServer.set_bus_volume_db(sound_bus, AUDIO_ON_DB)
	else:
		AudioServer.set_bus_volume_db(sound_bus, AUDIO_OFF_DB)

#ДЛЯ ПЕРВОГО РЕЖИМА

var current_mode1_level_data: Dictionary = {}

var mode1levels_data = [

	# --- 1–8 (треугольники) ---
	{"id": 1, "done": false, "kind": "triangle", "task_data": {"angle": "alpha", "func_name": "sin"}},
	{"id": 2, "done": false, "kind": "triangle", "task_data": {"angle": "alpha", "func_name": "cos"}},
	{"id": 3, "done": false, "kind": "triangle", "task_data": {"angle": "alpha", "func_name": "tg"}},
	{"id": 4, "done": false, "kind": "triangle", "task_data": {"angle": "beta", "func_name": "cos"}},
	{"id": 5, "done": false, "kind": "triangle", "task_data": {"angle": "beta", "func_name": "ctg"}},
	{"id": 6, "done": false, "kind": "triangle", "task_data": {"angle": "beta", "func_name": "sin"}},
	{"id": 7, "done": false, "kind": "triangle", "task_data": {"angle": "alpha", "func_name": "ctg"}},
	{"id": 8, "done": false, "kind": "triangle", "task_data": {"angle": "beta", "func_name": "tg"}},

	# --- 9–12 (круг) ---
	{"id": 9,  "done": false, "kind": "quarter",    "task_data": {"angle": 60,  "func_name": "cos"}},
	{"id": 10, "done": false, "kind": "quarter",    "task_data": {"angle": 45,  "func_name": "sin"}},
	{"id": 11, "done": false, "kind": "quarter",    "task_data": {"angle": 30,  "func_name": "sin"}},
	{"id": 12, "done": false, "kind": "up_half",    "task_data": {"angle": 120, "func_name": "cos"}},

	# --- дополнительные (для перелистывания) ---
	{"id": 13, "done": false, "kind": "up_half",    "task_data": {"angle": 150, "func_name": "sin"}},
	{"id": 14, "done": false, "kind": "up_half",    "task_data": {"angle": 135, "func_name": "tg"}},
	{"id": 15, "done": false, "kind": "right_half", "task_data": {"angle": 300, "func_name": "cos"}},
	{"id": 16, "done": false, "kind": "right_half", "task_data": {"angle": 330, "func_name": "sin"}},
	{"id": 17, "done": false, "kind": "right_half", "task_data": {"angle": 270, "func_name": "tg"}},
	{"id": 18, "done": false, "kind": "full_circle","task_data": {"angle": 360, "func_name": "cos"}},
	{"id": 19, "done": false, "kind": "full_circle","task_data": {"angle": 180, "func_name": "sin"}},
	{"id": 20, "done": false, "kind": "full_circle","task_data": {"angle": 90,  "func_name": "tg"}},
	{"id": 21, "done": false, "kind": "quarter",    "task_data": {"angle": 45,  "func_name": "cos"}},
	{"id": 22, "done": false, "kind": "quarter",    "task_data": {"angle": 30,  "func_name": "tg"}},
	{"id": 23, "done": false, "kind": "up_half",     "task_data": {"angle": 150, "func_name": "cos"}},
	{"id": 24, "done": false, "kind": "up_half",     "task_data": {"angle": 135, "func_name": "sin"}},
	{"id": 25, "done": false, "kind": "up_half",     "task_data": {"angle": 120, "func_name": "tg"}},
	{"id": 26, "done": false, "kind": "up_half",     "task_data": {"angle": 180, "func_name": "ctg"}},
	{"id": 27, "done": false, "kind": "right_half",  "task_data": {"angle": 300, "func_name": "sin"}},
	{"id": 28, "done": false, "kind": "right_half",  "task_data": {"angle": 330, "func_name": "cos"}},
	{"id": 29, "done": false, "kind": "right_half",  "task_data": {"angle": 270, "func_name": "tg"}},
	{"id": 30, "done": false, "kind": "right_half",  "task_data": {"angle": 240, "func_name": "ctg"}},
	{"id": 31, "done": false, "kind": "full_circle", "task_data": {"angle": 0,   "func_name": "cos"}},
	{"id": 32, "done": false, "kind": "full_circle", "task_data": {"angle": 30,  "func_name": "sin"}},
	{"id": 33, "done": false, "kind": "full_circle", "task_data": {"angle": 45,  "func_name": "tg"}},
	{"id": 34, "done": false, "kind": "full_circle", "task_data": {"angle": 60,  "func_name": "ctg"}},
	{"id": 35, "done": false, "kind": "full_circle", "task_data": {"angle": 90,  "func_name": "sin"}},
	{"id": 36, "done": false, "kind": "full_circle", "task_data": {"angle": 180, "func_name": "cos"}},
	{"id": 37, "done": false, "kind": "quarter",     "task_data": {"angle": 30,  "func_name": "cos"}},
	{"id": 38, "done": false, "kind": "quarter",     "task_data": {"angle": 45,  "func_name": "tg"}},
	{"id": 39, "done": false, "kind": "quarter",     "task_data": {"angle": 60,  "func_name": "ctg"}},
	{"id": 40, "done": false, "kind": "triangle",    "task_data": {"angle": "alpha", "func_name": "sin"}},
	{"id": 41, "done": false, "kind": "triangle",    "task_data": {"angle": "beta",  "func_name": "cos"}},
	{"id": 42, "done": false, "kind": "triangle",    "task_data": {"angle": "alpha", "func_name": "tg"}}
]


#ДЛЯ ВТОРОГО РЕЖИМА

var current_second_mode_type: String = ""
var second_mode_endless_unlocked: bool = false
