extends Node2D

@onready var button_pause: TextureButton = $UI/HBoxContainer/ButtonPause
@onready var normal_mode_done = $UI/HBoxContainer/NormalModeDone

@onready var mouse_pivot: Node2D = $Mouse
@onready var button_ccw: TextureButton = $UI/ButtonCCW
@onready var button_cw: TextureButton = $UI/ButtonCW

@onready var value_root: Node2D = $ObjectsCircle/Value
@onready var button_no_answer: TextureButton = $UI/ButtonNoAnswer

var buttons_map: Dictionary = {}

@onready var label_type: Label = $UI/Control/Type
@onready var label_function: Label = $UI/Control/Function
@onready var label_value: Label = $UI/Control/Value
@onready var label_angle: Label = $UI/Control/Angle
@onready var label_current_angle: Label = $UI/Control/CurrentAngle


var circle_angles: Array[int] = [
	0, 
	30, 
	45, 
	60, 
	90, 
	120, 
	135, 
	150, 
	180, 
	210, 
	225, 
	240, 
	270, 
	300, 
	315, 
	330, 
	360
]

var current_order_index: int = 0
var mode2_normal_order = [
	1, 2, 5, 6, 9, 10, 13, 14,
	7, 8, 11, 12, 15, 16,
	17, 18, 21, 22, 25,
	19,
	26, 29, 30, 20, 23, 24, 27, 28, 31, 32,
	33, 34, 35, 36, 37, 38, 41, 42, 39, 40, 43, 44, 45, 46, 47, 48,
	49, 50, 51, 52, 53, 54, 57, 58, 55, 56, 59, 60, 61, 62, 63, 64,
	3, 4, 65, 66, 67, 68
]

var current_angle_index := 0
var current_angle: int = 0

var current_level_id: int = 11
var current_level_data: Dictionary = {}

var is_rotating: bool = false
var rotation_duration := 0.3

func _ready() -> void:
	current_angle_index = 0
	current_angle = circle_angles[current_angle_index]
	mouse_pivot.rotation_degrees = -current_angle

	build_value_buttons_map()
	hide_all_value_buttons()

	load_current_ordered_level()
	update_current_angle_label()

func setup_mode_ui() -> void:
	if Global.current_second_mode_type == "normal":
		normal_mode_done.visible = true
	elif Global.current_second_mode_type == "endless":
		normal_mode_done.visible = false


func load_level_by_id(level_id: int) -> void:
	current_level_id = level_id
	current_level_data = get_level_data_by_id(level_id)

	if current_level_data.is_empty():
		push_warning("Не найден уровень с id = %s" % level_id)
		return

	update_level_labels()
	show_buttons_for_current_level()


func get_level_data_by_id(level_id: int) -> Dictionary:
	for item in Global.mode2levels_data:
		if item.get("id", -1) == level_id:
			return item
	return {}

func load_current_ordered_level() -> void:
	var level_id = mode2_normal_order[current_order_index]
	load_level_by_id(level_id)

func load_next_level() -> void:
	current_order_index += 1

	if current_order_index >= mode2_normal_order.size():
		current_order_index = 0  # или остановка, потом решим

	load_current_ordered_level()

func _on_button_smol_round_idle_pressed() -> void:
	load_next_level()

func build_value_buttons_map() -> void:
	buttons_map.clear()

	for value_group in value_root.get_children():
		for answer_area in value_group.get_children():
			if not (answer_area is Area2D):
				continue

			var parsed := parse_value_button_name(answer_area.name)
			#print("PARSE: ", answer_area.name, " -> ", parsed)
			if parsed.is_empty():
				push_warning("Не удалось распарсить кнопку: %s" % answer_area.name)
				continue

			var angle: int = parsed["angle"]
			var func_name: String = parsed["func"]

			if not buttons_map.has(angle):
				buttons_map[angle] = {}

			buttons_map[angle][func_name] = answer_area



func parse_value_button_name(node_name: String) -> Dictionary:
	var parts := node_name.split("_")

	if parts.size() < 3:
		return {}

	var angle_text := parts[parts.size() - 1]
	var func_name := parts[parts.size() - 2]

	if func_name not in ["sin", "cos", "tg", "ctg"]:
		return {}

	var value_parts: Array = parts.slice(0, parts.size() - 2)
	if value_parts.is_empty():
		return {}

	var value_text := "_".join(value_parts)
	var angle := int(angle_text)

	return {
		"value": value_text,
		"func": func_name,
		"angle": angle
	}
	
	


func hide_all_value_buttons() -> void:
	for angle in buttons_map.keys():
		for func_name in buttons_map[angle].keys():
			var area: Area2D = buttons_map[angle][func_name]
			area.visible = false

	button_no_answer.visible = false

func show_buttons_for_current_level() -> void:
	
	#--------------
	#ДЕБАГ
	
	
	print("=== show_buttons_for_current_level ===")
	hide_all_value_buttons()

	if current_level_data.is_empty():
		print("current_level_data is empty")
		return

	print("current_level_data = ", current_level_data)
	var func_name: String = current_level_data.get("func", "")
	var angle: int = current_angle
	
	print("display angle from mouse = ", current_angle)
	print("correct angle from level = ", current_level_data.get("angle", -1))
	
	var value: String = current_level_data.get("value", "")
	var group: String = get_function_group(func_name)

	print("func_name = ", func_name)
	print("angle = ", angle)
	print("value = ", value)
	print("group = ", group)
	
	#--------------
	
	
	hide_all_value_buttons()

	if current_level_data.is_empty():
		return

	#var func_name: String = current_level_data.get("func", "")
	#var angle: int = current_level_data.get("angle", -1)
	#var value: String = current_level_data.get("value", "")
	#var group: String = get_function_group(func_name)


	if not buttons_map.has(angle):
		print("buttons_map has NO angle: ", angle)
		return

	print("buttons_map[angle] keys = ", buttons_map[angle].keys())
	
	match group:
		"sin_cos":
			show_button_if_exists(angle, "sin")
			show_button_if_exists(angle, "cos")

		"tg_ctg":
			show_button_if_exists(angle, "tg")
			show_button_if_exists(angle, "ctg")

	if value == "no_value":
		button_no_answer.visible = true


func show_button_if_exists(angle: int, func_name: String) -> void:
	print("TRY SHOW -> angle=", angle, " func=", func_name)

	if not buttons_map.has(angle):
		print("NO ANGLE: ", angle)
		return

	if not buttons_map[angle].has(func_name):
		print("NO FUNC: ", func_name, " at angle ", angle)
		return

	var area: Area2D = buttons_map[angle][func_name]
	print("FOUND BUTTON: ", area.name)

	area.visible = true
	print("area.visible = ", area.visible)
	print("area.is_visible_in_tree() = ", area.is_visible_in_tree())

	var sprite := area.get_node_or_null("Sprite2D")
	if sprite:
		print("sprite.visible = ", sprite.visible)
		print("sprite.is_visible_in_tree() = ", sprite.is_visible_in_tree())

#func _on_normal_mode_done_pressed() -> void:
	#Global.second_mode_endless_unlocked = true
	#get_tree().change_scene_to_file("res://scenes/SecondMode/second_mode_select.tscn")


func _on_button_pause_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/SecondMode/second_mode_select.tscn")

func apply_mouse_angle() -> void:
	current_angle = circle_angles[current_angle_index]
	mouse_pivot.rotation_degrees = -current_angle

# =========================
# ВРАЩЕНИЕ
# =========================

func rotate_to_index(new_index: int) -> void:
	if is_rotating:
		return

	is_rotating = true
	hide_all_value_buttons()

	var old_angle = circle_angles[current_angle_index]
	var new_angle = circle_angles[new_index]

	var delta = new_angle - old_angle

	if delta > 180:
		delta -= 360
	elif delta < -180:
		delta += 360

	current_angle_index = new_index
	current_angle = new_angle
	update_current_angle_label()
	

	var tween = create_tween()
	tween.tween_property(
		mouse_pivot,
		"rotation_degrees",
		mouse_pivot.rotation_degrees - delta,
		rotation_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	tween.finished.connect(_on_rotation_finished)
	

func _on_rotation_finished() -> void:
	is_rotating = false
	show_buttons_for_current_level()

# =========================
# КНОПКИ
# =========================

func _on_button_ccw_pressed() -> void:
	var new_index = current_angle_index + 1
	if new_index >= circle_angles.size():
		new_index = 0
	
	rotate_to_index(new_index)

func _on_button_cw_pressed() -> void:
	var new_index = current_angle_index - 1
	if new_index < 0:
		new_index = circle_angles.size() - 1
	
	rotate_to_index(new_index)


func get_function_group(func_name: String) -> String:
	if func_name in ["sin", "cos"]:
		return "sin_cos"
	if func_name in ["tg", "ctg"]:
		return "tg_ctg"
	return ""

# =========================
# ОТЛАДКА ЛЕЙБЛЫ
# =========================
func update_level_labels() -> void:
	if current_level_data.is_empty():
		return

	label_type.text = "type: " + str(current_level_data.get("type", ""))
	label_function.text = "function: " + str(current_level_data.get("func", ""))
	label_value.text = "value: " + str(current_level_data.get("value", ""))
	label_angle.text = "angle: " + str(current_level_data.get("angle", ""))

	update_current_angle_label()

func update_current_angle_label() -> void:
	label_current_angle.text = "current_angle: " + str(current_angle)
