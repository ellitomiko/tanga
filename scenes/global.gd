extends Node


#ДЛЯ НАСТРОЕК МУЗЫКИ
const AUDIO_OFF_DB := -80.0
const AUDIO_ON_DB := 0.0

var music_bus := AudioServer.get_bus_index("Music")
var sound_bus := AudioServer.get_bus_index("Sound")


var settings_return_scene_path: String = "res://scenes/MainUI/main_menu.tscn"


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
var mode2levels_data = [
	{ "id": 1, "type": "find_angle", "func": "sin", "value": "0", "angle": 0 },
	{ "id": 2, "type": "find_angle", "func": "cos", "value": "1", "angle": 0 },
	{ "id": 3, "type": "find_angle", "func": "tg", "value": "0", "angle": 0 },
	{ "id": 4, "type": "find_angle", "func": "ctg", "value": "no_value", "angle": 0 },

	{ "id": 5, "type": "find_angle", "func": "sin", "value": "1_2", "angle": 30 },
	{ "id": 6, "type": "find_angle", "func": "cos", "value": "sqr3_2", "angle": 30 },
	{ "id": 7, "type": "find_angle", "func": "tg", "value": "1_sqr3", "angle": 30 },
	{ "id": 8, "type": "find_angle", "func": "ctg", "value": "sqr3", "angle": 30 },

	{ "id": 9, "type": "find_angle", "func": "sin", "value": "sqr2_2", "angle": 45 },
	{ "id": 10, "type": "find_angle", "func": "cos", "value": "sqr2_2", "angle": 45 },
	{ "id": 11, "type": "find_angle", "func": "tg", "value": "1", "angle": 45 },
	{ "id": 12, "type": "find_angle", "func": "ctg", "value": "1", "angle": 45 },

	{ "id": 13, "type": "find_angle", "func": "sin", "value": "sqr3_2", "angle": 60 },
	{ "id": 14, "type": "find_angle", "func": "cos", "value": "1_2", "angle": 60 },
	{ "id": 15, "type": "find_angle", "func": "tg", "value": "sqr3", "angle": 60 },
	{ "id": 16, "type": "find_angle", "func": "ctg", "value": "1_sqr3", "angle": 60 },

	{ "id": 17, "type": "find_angle", "func": "sin", "value": "1", "angle": 90 },
	{ "id": 18, "type": "find_angle", "func": "cos", "value": "0", "angle": 90 },
	{ "id": 19, "type": "find_angle", "func": "tg", "value": "no_value", "angle": 90 },
	{ "id": 20, "type": "find_angle", "func": "ctg", "value": "0", "angle": 90 },

	{ "id": 21, "type": "find_angle", "func": "sin", "value": "sqr3_2", "angle": 120 },
	{ "id": 22, "type": "find_angle", "func": "cos", "value": "-1_2", "angle": 120 },
	{ "id": 23, "type": "find_angle", "func": "tg", "value": "-sqr3", "angle": 120 },
	{ "id": 24, "type": "find_angle", "func": "ctg", "value": "-1_sqr3", "angle": 120 },

	{ "id": 25, "type": "find_angle", "func": "sin", "value": "sqr2_2", "angle": 135 },
	{ "id": 26, "type": "find_angle", "func": "cos", "value": "-sqr2_2", "angle": 135 },
	{ "id": 27, "type": "find_angle", "func": "tg", "value": "-1", "angle": 135 },
	{ "id": 28, "type": "find_angle", "func": "ctg", "value": "-1", "angle": 135 },

	{ "id": 29, "type": "find_angle", "func": "sin", "value": "1_2", "angle": 150 },
	{ "id": 30, "type": "find_angle", "func": "cos", "value": "-sqr3_2", "angle": 150 },
	{ "id": 31, "type": "find_angle", "func": "tg", "value": "-1_sqr3", "angle": 150 },
	{ "id": 32, "type": "find_angle", "func": "ctg", "value": "-sqr3", "angle": 150 },

	{ "id": 33, "type": "find_angle", "func": "sin", "value": "0", "angle": 180 },
	{ "id": 34, "type": "find_angle", "func": "cos", "value": "-1", "angle": 180 },
	{ "id": 35, "type": "find_angle", "func": "tg", "value": "0", "angle": 180 },
	{ "id": 36, "type": "find_angle", "func": "ctg", "value": "no_value", "angle": 180 },

	{ "id": 37, "type": "find_angle", "func": "sin", "value": "-1_2", "angle": 210 },
	{ "id": 38, "type": "find_angle", "func": "cos", "value": "-sqr3_2", "angle": 210 },
	{ "id": 39, "type": "find_angle", "func": "tg", "value": "1_sqr3", "angle": 210 },
	{ "id": 40, "type": "find_angle", "func": "ctg", "value": "sqr3", "angle": 210 },

	{ "id": 41, "type": "find_angle", "func": "sin", "value": "-sqr2_2", "angle": 225 },
	{ "id": 42, "type": "find_angle", "func": "cos", "value": "-sqr2_2", "angle": 225 },
	{ "id": 43, "type": "find_angle", "func": "tg", "value": "1", "angle": 225 },
	{ "id": 44, "type": "find_angle", "func": "ctg", "value": "1", "angle": 225 },

	{ "id": 45, "type": "find_angle", "func": "sin", "value": "-sqr3_2", "angle": 240 },
	{ "id": 46, "type": "find_angle", "func": "cos", "value": "-1_2", "angle": 240 },
	{ "id": 47, "type": "find_angle", "func": "tg", "value": "sqr3", "angle": 240 },
	{ "id": 48, "type": "find_angle", "func": "ctg", "value": "1_sqr3", "angle": 240 },

	{ "id": 49, "type": "find_angle", "func": "sin", "value": "-1", "angle": 270 },
	{ "id": 50, "type": "find_angle", "func": "cos", "value": "0", "angle": 270 },
	{ "id": 51, "type": "find_angle", "func": "tg", "value": "no_value", "angle": 270 },
	{ "id": 52, "type": "find_angle", "func": "ctg", "value": "0", "angle": 270 },

	{ "id": 53, "type": "find_angle", "func": "sin", "value": "-sqr3_2", "angle": 300 },
	{ "id": 54, "type": "find_angle", "func": "cos", "value": "1_2", "angle": 300 },
	{ "id": 55, "type": "find_angle", "func": "tg", "value": "-sqr3", "angle": 300 },
	{ "id": 56, "type": "find_angle", "func": "ctg", "value": "-1_sqr3", "angle": 300 },

	{ "id": 57, "type": "find_angle", "func": "sin", "value": "-sqr2_2", "angle": 315 },
	{ "id": 58, "type": "find_angle", "func": "cos", "value": "sqr2_2", "angle": 315 },
	{ "id": 59, "type": "find_angle", "func": "tg", "value": "-1", "angle": 315 },
	{ "id": 60, "type": "find_angle", "func": "ctg", "value": "-1", "angle": 315 },

	{ "id": 61, "type": "find_angle", "func": "sin", "value": "-1_2", "angle": 330 },
	{ "id": 62, "type": "find_angle", "func": "cos", "value": "sqr3_2", "angle": 330 },
	{ "id": 63, "type": "find_angle", "func": "tg", "value": "-1_sqr3", "angle": 330 },
	{ "id": 64, "type": "find_angle", "func": "ctg", "value": "-sqr3", "angle": 330 },

	{ "id": 65, "type": "find_angle", "func": "sin", "value": "0", "angle": 360 },
	{ "id": 66, "type": "find_angle", "func": "cos", "value": "1", "angle": 360 },
	{ "id": 67, "type": "find_angle", "func": "tg", "value": "0", "angle": 360 },
	{ "id": 68, "type": "find_angle", "func": "ctg", "value": "no_value", "angle": 360 },
	
	{ "id": 69, "type": "find_value", "func": "sin", "angle": 0, "value": "0" },
	{ "id": 70, "type": "find_value", "func": "cos", "angle": 0, "value": "1" },
	{ "id": 71, "type": "find_value", "func": "tg", "angle": 0, "value": "0" },
	{ "id": 72, "type": "find_value", "func": "ctg", "angle": 0, "value": "no_value" },

	{ "id": 73, "type": "find_value", "func": "sin", "angle": 30, "value": "1_2" },
	{ "id": 74, "type": "find_value", "func": "cos", "angle": 30, "value": "sqr3_2" },
	{ "id": 75, "type": "find_value", "func": "tg", "angle": 30, "value": "1_sqr3" },
	{ "id": 76, "type": "find_value", "func": "ctg", "angle": 30, "value": "sqr3" },

	{ "id": 77, "type": "find_value", "func": "sin", "angle": 45, "value": "sqr2_2" },
	{ "id": 78, "type": "find_value", "func": "cos", "angle": 45, "value": "sqr2_2" },
	{ "id": 79, "type": "find_value", "func": "tg", "angle": 45, "value": "1" },
	{ "id": 80, "type": "find_value", "func": "ctg", "angle": 45, "value": "1" },

	{ "id": 81, "type": "find_value", "func": "sin", "angle": 60, "value": "sqr3_2" },
	{ "id": 82, "type": "find_value", "func": "cos", "angle": 60, "value": "1_2" },
	{ "id": 83, "type": "find_value", "func": "tg", "angle": 60, "value": "sqr3" },
	{ "id": 84, "type": "find_value", "func": "ctg", "angle": 60, "value": "1_sqr3" },

	{ "id": 85, "type": "find_value", "func": "sin", "angle": 90, "value": "1" },
	{ "id": 86, "type": "find_value", "func": "cos", "angle": 90, "value": "0" },
	{ "id": 87, "type": "find_value", "func": "tg", "angle": 90, "value": "no_value" },
	{ "id": 88, "type": "find_value", "func": "ctg", "angle": 90, "value": "0" },

	{ "id": 89, "type": "find_value", "func": "sin", "angle": 120, "value": "sqr3_2" },
	{ "id": 90, "type": "find_value", "func": "cos", "angle": 120, "value": "-1_2" },
	{ "id": 91, "type": "find_value", "func": "tg", "angle": 120, "value": "-sqr3" },
	{ "id": 92, "type": "find_value", "func": "ctg", "angle": 120, "value": "-1_sqr3" },

	{ "id": 93, "type": "find_value", "func": "sin", "angle": 135, "value": "sqr2_2" },
	{ "id": 94, "type": "find_value", "func": "cos", "angle": 135, "value": "-sqr2_2" },
	{ "id": 95, "type": "find_value", "func": "tg", "angle": 135, "value": "-1" },
	{ "id": 96, "type": "find_value", "func": "ctg", "angle": 135, "value": "-1" },

	{ "id": 97, "type": "find_value", "func": "sin", "angle": 150, "value": "1_2" },
	{ "id": 98, "type": "find_value", "func": "cos", "angle": 150, "value": "-sqr3_2" },
	{ "id": 99, "type": "find_value", "func": "tg", "angle": 150, "value": "-1_sqr3" },
	{ "id": 100, "type": "find_value", "func": "ctg", "angle": 150, "value": "-sqr3" },

	{ "id": 101, "type": "find_value", "func": "sin", "angle": 180, "value": "0" },
	{ "id": 102, "type": "find_value", "func": "cos", "angle": 180, "value": "-1" },
	{ "id": 103, "type": "find_value", "func": "tg", "angle": 180, "value": "0" },
	{ "id": 104, "type": "find_value", "func": "ctg", "angle": 180, "value": "no_value" },

	{ "id": 105, "type": "find_value", "func": "sin", "angle": 210, "value": "-1_2" },
	{ "id": 106, "type": "find_value", "func": "cos", "angle": 210, "value": "-sqr3_2" },
	{ "id": 107, "type": "find_value", "func": "tg", "angle": 210, "value": "1_sqr3" },
	{ "id": 108, "type": "find_value", "func": "ctg", "angle": 210, "value": "sqr3" },

	{ "id": 109, "type": "find_value", "func": "sin", "angle": 225, "value": "-sqr2_2" },
	{ "id": 110, "type": "find_value", "func": "cos", "angle": 225, "value": "-sqr2_2" },
	{ "id": 111, "type": "find_value", "func": "tg", "angle": 225, "value": "1" },
	{ "id": 112, "type": "find_value", "func": "ctg", "angle": 225, "value": "1" },

	{ "id": 113, "type": "find_value", "func": "sin", "angle": 240, "value": "-sqr3_2" },
	{ "id": 114, "type": "find_value", "func": "cos", "angle": 240, "value": "-1_2" },
	{ "id": 115, "type": "find_value", "func": "tg", "angle": 240, "value": "sqr3" },
	{ "id": 116, "type": "find_value", "func": "ctg", "angle": 240, "value": "1_sqr3" },

	{ "id": 117, "type": "find_value", "func": "sin", "angle": 270, "value": "-1" },
	{ "id": 118, "type": "find_value", "func": "cos", "angle": 270, "value": "0" },
	{ "id": 119, "type": "find_value", "func": "tg", "angle": 270, "value": "no_value" },
	{ "id": 120, "type": "find_value", "func": "ctg", "angle": 270, "value": "0" },

	{ "id": 121, "type": "find_value", "func": "sin", "angle": 300, "value": "-sqr3_2" },
	{ "id": 122, "type": "find_value", "func": "cos", "angle": 300, "value": "1_2" },
	{ "id": 123, "type": "find_value", "func": "tg", "angle": 300, "value": "-sqr3" },
	{ "id": 124, "type": "find_value", "func": "ctg", "angle": 300, "value": "-1_sqr3" },

	{ "id": 125, "type": "find_value", "func": "sin", "angle": 315, "value": "-sqr2_2" },
	{ "id": 126, "type": "find_value", "func": "cos", "angle": 315, "value": "sqr2_2" },
	{ "id": 127, "type": "find_value", "func": "tg", "angle": 315, "value": "-1" },
	{ "id": 128, "type": "find_value", "func": "ctg", "angle": 315, "value": "-1" },

	{ "id": 129, "type": "find_value", "func": "sin", "angle": 330, "value": "-1_2" },
	{ "id": 130, "type": "find_value", "func": "cos", "angle": 330, "value": "sqr3_2" },
	{ "id": 131, "type": "find_value", "func": "tg", "angle": 330, "value": "-1_sqr3" },
	{ "id": 132, "type": "find_value", "func": "ctg", "angle": 330, "value": "-sqr3" },

	{ "id": 133, "type": "find_value", "func": "sin", "angle": 360, "value": "0" },
	{ "id": 134, "type": "find_value", "func": "cos", "angle": 360, "value": "1" },
	{ "id": 135, "type": "find_value", "func": "tg", "angle": 360, "value": "0" },
	{ "id": 136, "type": "find_value", "func": "ctg", "angle": 360, "value": "no_value" }
]
