extends Node2D


# ------------- ДАННЫЕ УРОВНЯ --------------
var current_level_index: int = 34
var current_level_data: Dictionary = {}
# ------------------------------------------


# ------------- ОТЛАДКА --------------
@onready var id_label: Label = $UI/Control/ID
@onready var function_label: Label = $UI/Control/Function
@onready var value_label: Label = $UI/Control/Value
@onready var angle_label: Label = $UI/Control/Angle
@onready var current_angle_label: Label = $UI/Control/CurrentAngle
# -------------------------------------


# ------------- ВЫРАЖЕНИЕ --------------
@onready var final_angle_label: Label = $UI/RightSide/EquationFinal/AngleSlot

@onready var reference_function_label: Label = $UI/RightSide/EquationReference/Function
@onready var reference_value_rect: TextureRect = $UI/RightSide/EquationReference/Value
# --------------------------------------


# ------------- ОТОБРАЖЕНИЕ НА КРУГЕ --------------
@onready var angles_sin_cos: Control = $UI/CheeseBlock/Circle/Angles_sin_cos
@onready var angles_tg_ctg: Control = $UI/CheeseBlock/Circle/Angles_tg_ctg

const TG_CTG_ANGLE_GROUPS := {
	0: "0_180",
	180: "0_180",
	
	30: "30",
	45: "45",
	60: "60",
	
	90: "90_270",
	270: "90_270",
	
	120: "120_300",
	300: "120_300",
	
	135: "135_315",
	315: "135_315",
	
	150: "150_330",
	330: "150_330",
	
	210: "210",
	225: "225",
	240: "240"
}


var current_circle_display_node: CanvasItem = null
var circle_display_tween: Tween = null

var circle_display_fade_duration: float = 0.12




var current_answer_options: Array[TextureRect] = []
var selected_answer_node: TextureRect = null
var selected_answer_func: String = ""
var selected_answer_value: String = ""

var answer_blink_tweens: Dictionary = {}

var answer_idle_alpha: float = 1.0
var answer_blink_alpha: float = 0.72
var answer_disabled_alpha: float = 0.35
var answer_blink_duration: float = 0.38
# -------------------------------------------------




# ------------- МЫШКА И КНОПКИ --------------
@onready var mouse_pivot: Control = $UI/CheeseBlock/Circle/Mouse
@onready var button_ccw: TextureButton = $UI/CheeseBlock/HBoxContainer/ButtonCCW
@onready var button_cw: TextureButton = $UI/CheeseBlock/HBoxContainer/ButtonCW

const CIRCLE_ANGLES := [
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
	330
]

var current_angle_index: int = 0
var current_angle: int = 0

var target_angle_index: int = 0
var target_angle: int = 0

var is_rotating: bool = false
var rotation_duration: float = 0.3
# -------------------------------------------









func _ready() -> void:
	setup_mouse_start_position()
	load_level_by_index(current_level_index)









# ------------- ДАННЫЕ УРОВНЯ --------------
func load_level_by_index(level_index: int) -> void:
	if Global.mode2levels_data.is_empty():
		print("mode2levels_data пустая!")
		return
	
	if level_index < 0 or level_index >= Global.mode2levels_data.size():
		print("Уровня с таким индексом нет: ", level_index)
		return
	
	current_level_index = level_index
	current_level_data = Global.mode2levels_data[current_level_index]
	
	setup_level()


func setup_level() -> void:
	setup_debug_level()
	setup_reference_equation()
	update_circle_display()
# ------------------------------------------









# ------------- ОТЛАДКА --------------
func setup_debug_level() -> void:
	id_label.text = "ID: " + str(current_level_data.get("id", ""))
	function_label.text = "Function: " + str(current_level_data.get("func", ""))
	value_label.text = "Value: " + str(current_level_data.get("value", ""))
	angle_label.text = "Angle: " + str(current_level_data.get("angle", "")) + "°"


func update_current_angle_debug() -> void:
	current_angle_label.text = "CurrentAngle: " + str(current_angle) + "°"
	print("current_angle: ", current_angle)
# -------------------------------------









# ------------- ОТОБРАЖЕНИЕ НА КРУГЕ --------------
func hide_circle_display() -> void:
	angles_sin_cos.visible = false
	angles_tg_ctg.visible = false
	
	for child in angles_sin_cos.get_children():
		child.visible = false
		if child is CanvasItem:
			set_display_alpha(child, 1.0)
	
	for child in angles_tg_ctg.get_children():
		child.visible = false
		if child is CanvasItem:
			set_display_alpha(child, 1.0)
	
	current_circle_display_node = null



func fade_out_current_circle_display() -> void:
	if circle_display_tween != null:
		circle_display_tween.kill()
		circle_display_tween = null
	
	if current_circle_display_node == null:
		hide_circle_display()
		return
	
	circle_display_tween = create_tween()
	circle_display_tween.tween_property(
		current_circle_display_node,
		"modulate:a",
		0.0,
		circle_display_fade_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	circle_display_tween.finished.connect(hide_circle_display)




func get_angle_display_node_name(func_name: String, angle: int) -> String:
	if func_name == "sin" or func_name == "cos":
		return str(angle)
	
	if func_name == "tg" or func_name == "ctg":
		return TG_CTG_ANGLE_GROUPS.get(angle, "")
	
	return ""


func update_circle_display() -> void:
	hide_circle_display()
	
	var func_name: String = str(current_level_data.get("func", ""))
	var angle_node_name: String = get_angle_display_node_name(func_name, current_angle)
	
	if angle_node_name == "":
		print("Не найдено имя группы для угла: ", current_angle, " и функции: ", func_name)
		return
	
	var display_group := get_circle_display_group_by_function(func_name)
	
	if display_group == null:
		print("Не найдена группа отображения для функции: ", func_name)
		return
	
	var angle_node := display_group.get_node_or_null(angle_node_name)
	
	if angle_node == null:
		print("Не найдена нода угла: ", angle_node_name, " внутри ", display_group.name)
		return
	
	display_group.visible = true
	angle_node.visible = true
	
	if angle_node is CanvasItem:
		current_circle_display_node = angle_node
		set_display_alpha(current_circle_display_node, 0.0)
		
		if circle_display_tween != null:
			circle_display_tween.kill()
		
		circle_display_tween = create_tween()
		circle_display_tween.tween_property(
			current_circle_display_node,
			"modulate:a",
			1.0,
			circle_display_fade_duration
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func get_circle_display_group_by_function(func_name: String) -> Control:
	if func_name == "sin" or func_name == "cos":
		return angles_sin_cos
	
	if func_name == "tg" or func_name == "ctg":
		return angles_tg_ctg
	
	return null



func set_display_alpha(node: CanvasItem, alpha: float) -> void:
	var color := node.modulate
	color.a = alpha
	node.modulate = color

func reset_selected_answer() -> void:
	selected_answer_node = null
	selected_answer_func = ""
	selected_answer_value = ""


func stop_answer_blinking() -> void:
	for option in answer_blink_tweens.keys():
		var tween: Tween = answer_blink_tweens[option]
		if tween != null:
			tween.kill()
	
	answer_blink_tweens.clear()
# -------------------------------------------------








# ------------- МЫШКА --------------
func setup_mouse_start_position() -> void:
	current_angle_index = 0
	current_angle = int(CIRCLE_ANGLES[current_angle_index])
	
	target_angle_index = current_angle_index
	target_angle = current_angle
	
	apply_mouse_angle()
	update_angle_output()


func apply_mouse_angle() -> void:
	mouse_pivot.rotation_degrees = -current_angle


func update_angle_output() -> void:
	update_final_angle()
	update_current_angle_debug()


func rotate_to_index(new_index: int) -> void:
	if is_rotating:
		return
	
	is_rotating = true
	fade_out_current_circle_display()
	
	var old_angle: int = int(CIRCLE_ANGLES[current_angle_index])
	var new_angle: int = int(CIRCLE_ANGLES[new_index])
	
	var delta: int = new_angle - old_angle
	
	if delta > 180:
		delta -= 360
	elif delta < -180:
		delta += 360
	
	target_angle_index = new_index
	target_angle = new_angle
	
	var tween := create_tween()
	tween.tween_property(
		mouse_pivot,
		"rotation_degrees",
		mouse_pivot.rotation_degrees - delta,
		rotation_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	tween.finished.connect(_on_rotation_finished)


func _on_rotation_finished() -> void:
	current_angle_index = target_angle_index
	current_angle = target_angle
	
	is_rotating = false
	
	update_angle_output()
	update_circle_display()


# ----------------------------------








# ------------- ВЫРАЖЕНИЕ --------------
func update_final_angle() -> void:
	final_angle_label.text = str(current_angle) + "°"


func get_value_texture(value_key: String) -> Texture2D:
	if value_key == "no_value":
		return null
	
	var texture_path := "res://textures/secondMode/values/" + value_key + ".png"
	var texture := load(texture_path)
	
	if texture == null:
		print("Не найдена текстура значения: ", texture_path)
		return null
	
	return texture

func setup_reference_equation() -> void:
	var func_name: String = str(current_level_data.get("func", ""))
	var value_key: String = str(current_level_data.get("value", ""))
	
	reference_function_label.text = func_name
	reference_value_rect.texture = get_value_texture(value_key)
# --------------------------------------





# ------------- КНОПКИ --------------
func _on_button_ccw_pressed() -> void:
	var new_index := current_angle_index + 1
	
	if new_index >= CIRCLE_ANGLES.size():
		new_index = 0
	
	rotate_to_index(new_index)


func _on_button_cw_pressed() -> void:
	var new_index := current_angle_index - 1
	
	if new_index < 0:
		new_index = CIRCLE_ANGLES.size() - 1
	
	rotate_to_index(new_index)
# -------------------------------------------
