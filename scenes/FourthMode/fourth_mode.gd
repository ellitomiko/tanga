extends Node2D

const FIRST_FOURTH_MODE_TASK_INDEX := 17 - 1

var current_task_index: int = FIRST_FOURTH_MODE_TASK_INDEX
var current_task: Dictionary = {}


# ------------- ОТЛАДКА --------------
@onready var id_label: Label = $UI/Control/ID
@onready var type_label: Label = $UI/Control/Type
@onready var function_label: Label = $UI/Control/Function
@onready var angle_label: Label = $UI/Control/Angle
@onready var value_label: Label = $UI/Control/Value
# -------------------------------------

# ------------- ВЫРАЖЕНИЕ --------------
@onready var function_slot: TextureRect = $UI/Equation/FunctionSlot
@onready var function_equation_label: Label = $UI/Equation/Function

@onready var angle_slot: TextureRect = $UI/Equation/AngleSlot
@onready var angle_equation_label: Label = $UI/Equation/Angle

@onready var value_slot: TextureRect = $UI/Equation/ValueSlot
@onready var equal_label: Label = $UI/Equation/Equal
# ---------------------------------------



# ------------- КРУГ --------------
@onready var av_root: Control = $UI/circle/AV
@onready var fv_root: Control = $UI/circle/FV
# ---------------------------------


# ------------- КАРТОЧКИ --------------
@onready var cards_angles: Control = $UI/RightSide/Angles
@onready var cards_functions: Control = $UI/RightSide/Functions
# -------------------------------------


# ------------- ПРОВЕРКА ВЫРАЖЕНИЯ --------------
@onready var button_done: TextureButton = $UI/ButtonDone
@onready var counter_label: Label = $UI/COUNTER
@onready var record_label: Label = $UI/RECORD

const CARD_CORRECT_TEXTURE := preload("res://textures/fourthMode/card_correct.png")
const CARD_WRONG_TEXTURE := preload("res://textures/fourthMode/card_wrong.png")

const EQUATION_DEFAULT_COLOR := Color("#7864CC")
const EQUATION_CORRECT_COLOR := Color("#008D02")
const EQUATION_WRONG_COLOR := Color("#BB0000")
const TRANSITION_COLOR := Color("#7864CC")

var counter_value: int = 0
var is_transitioning: bool = false
@onready var transition_overlay: ColorRect = $UI/TransitionOverlay

const LOSS_SCREEN_SCENE := preload("res://scenes/FourthMode/fourth_mode_loss.tscn")
var loss_screen: Control = null
# ----------------------------------------------






func _ready() -> void:
	randomize()
	current_task = Global.FOURTH_MODE_TASKS[current_task_index]
	

	setup_level()
	update_counter()
	update_record_label()




func setup_level() -> void:
	setup_debug_task()
	setup_equation()
	setup_circle()
	setup_cards()





# ------------- ОТЛАДКА --------------
func setup_debug_task() -> void:
	id_label.text = "ID: " + str(current_task["id"])
	type_label.text = "Type: " + str(current_task["format"])
	function_label.text = "Function: " + str(current_task["function"])
	angle_label.text = "Angle: " + str(current_task["angle"])
	value_label.text = "Value: " + str(current_task["value"])
# ------------------------------------





# ------------- ВЫРАЖЕНИЕ --------------
func setup_equation() -> void:
	var task_format: String = str(current_task["format"])
	var task_function: String = str(current_task["function"])
	var task_angle: int = int(current_task["angle"])

	value_slot.visible = true

	if task_format == "FV":
		function_slot.visible = true
		function_equation_label.visible = false

		angle_slot.visible = false
		angle_equation_label.visible = true
		angle_equation_label.text = str(task_angle) + "°"

	elif task_format == "AV":
		function_slot.visible = false
		function_equation_label.visible = true
		function_equation_label.text = task_function

		angle_slot.visible = true
		angle_equation_label.visible = false
# -------------------------------------






# ------------- КРУГ --------------
func setup_circle() -> void:
	var task_format: String = str(current_task["format"])
	var task_function: String = str(current_task["function"])
	var task_angle: int = int(current_task["angle"])
	var task_value: String = str(current_task["value"])

	# Перед настройкой нового задания скрываем все точки углов.
	# Это нужно, чтобы от прошлого задания на круге ничего не осталось.
	for child in av_root.get_children():
		child.visible = false

	# Скрываем все группы FV: sin, cos, tg, ctg.
	# Заодно скрываем все вложенные визуальные варианты внутри каждой группы.
	for function_group in fv_root.get_children():
		function_group.visible = false

		for child in function_group.get_children():
			child.visible = false

	# Формат AV:
	# на круге должна отображаться точка конкретного угла.
	if task_format == "AV":
		av_root.visible = true
		fv_root.visible = false

		# В AV ноды называются просто по углу:
		# 0, 30, 45, 60 и так далее.
		var angle_node := av_root.get_node_or_null(str(task_angle))

		# Если такая точка найдена, показываем её.
		if angle_node != null:
			angle_node.visible = true

	# Формат FV:
	# на круге должна отображаться визуализация значения функции.
	elif task_format == "FV":
		av_root.visible = false
		fv_root.visible = true

		var visual_name := ""

		# Если у функции нет значения, на круге ничего не показываем.
		if task_value == "no_answer":
			visual_name = ""

		# Для нулевых значений используем общий вариант:
		# sin_zero, cos_zero, tg_zero, ctg_zero.
		elif task_value == "0":
			visual_name = task_function + "_zero"

		# Для отрицательных значений имя собирается без pos:
		# sin_neg_1_2, cos_neg_sqrt3_2, tg_neg_1 и так далее.
		elif task_value.begins_with("neg_"):
			visual_name = task_function + "_" + task_value

		# Для положительных значений добавляем pos:
		# sin_pos_1_2, cos_pos_sqrt3_2, tg_pos_sqrt3 и так далее.
		else:
			visual_name = task_function + "_pos_" + task_value

		# Если visual_name пустой, значит это no_answer.
		# В таком случае круг остаётся пустым.
		if visual_name == "":
			return

		# Находим группу нужной функции:
		# UI/circle/FV/sin или cos, tg, ctg.
		var function_group := fv_root.get_node_or_null(task_function)

		# Если группа функции не найдена, дальше ничего не делаем.
		if function_group == null:
			return

		function_group.visible = true

		# Находим конкретный визуальный объект внутри группы функции.
		var visual_node := function_group.get_node_or_null(visual_name)

		# Если объект найден, показываем его.
		if visual_node != null:
			visual_node.visible = true
# -------------------------------------




# ------------- КАРТОЧКИ --------------
func setup_cards() -> void:
	var task_format: String = str(current_task["format"])

	# Переключаем только те группы, которые зависят от формата задания.
	# Values всегда остаётся видимым, потому что значение всегда неизвестно.
	if task_format == "FV":
		cards_angles.visible = false
		cards_functions.visible = true

	elif task_format == "AV":
		cards_angles.visible = true
		cards_functions.visible = false
# -------------------------------------




# ------------- ПРОВЕРКА ОТВЕТА --------------
func _on_button_done_pressed() -> void:
	check_answer()

func check_answer() -> void:
	if is_transitioning:
		return

	var task_format: String = str(current_task["format"])

	if not is_answer_filled(task_format):
		print("Ответ не заполнен")
		return

	if not is_current_answer_correct():
		print("Неправильно")

		is_transitioning = true
		button_done.disabled = true

		apply_answer_feedback(false)
		update_record()

		await get_tree().create_timer(0.45).timeout
		show_loss_screen()

		return

	counter_value += 1
	update_counter()
	print("Правильно")

	apply_answer_feedback(true)

	await get_tree().create_timer(0.35).timeout
	await play_transition_to_next_level()


func update_record_label() -> void:
	record_label.text = "Рекорд: " + str(Global.fourth_mode_record)


func update_record() -> void:
	if counter_value > Global.fourth_mode_record:
		Global.fourth_mode_record = counter_value
		update_record_label()

func is_answer_filled(task_format: String) -> bool:
	if task_format == "FV":
		return function_slot.current_value != "" and value_slot.current_value != ""

	if task_format == "AV":
		return angle_slot.current_value != "" and value_slot.current_value != ""

	return false

func is_current_answer_correct() -> bool:
	var task_format: String = str(current_task["format"])
	var task_function: String = str(current_task["function"])
	var task_angle: String = str(current_task["angle"])
	var task_value: String = str(current_task["value"])

	if task_format == "FV":
		return (
			function_slot.current_value == task_function
			and value_slot.current_value == task_value
		)

	if task_format == "AV":
		return (
			angle_slot.current_value == task_angle
			and value_slot.current_value == task_value
		)

	return false



func apply_answer_feedback(is_correct: bool) -> void:
	var card_texture := CARD_CORRECT_TEXTURE
	var label_color := EQUATION_CORRECT_COLOR

	if not is_correct:
		card_texture = CARD_WRONG_TEXTURE
		label_color = EQUATION_WRONG_COLOR

	var task_format: String = str(current_task["format"])

	if task_format == "FV":
		function_slot.set_card_texture(card_texture)
		value_slot.set_card_texture(card_texture)

	elif task_format == "AV":
		angle_slot.set_card_texture(card_texture)
		value_slot.set_card_texture(card_texture)

	function_equation_label.add_theme_color_override("font_color", label_color)
	angle_equation_label.add_theme_color_override("font_color", label_color)
	equal_label.add_theme_color_override("font_color", label_color)

func reset_answer_feedback() -> void:
	function_slot.reset_card_texture()
	angle_slot.reset_card_texture()
	value_slot.reset_card_texture()

	function_equation_label.add_theme_color_override("font_color", EQUATION_DEFAULT_COLOR)
	angle_equation_label.add_theme_color_override("font_color", EQUATION_DEFAULT_COLOR)
	equal_label.add_theme_color_override("font_color", EQUATION_DEFAULT_COLOR)
# --------------------------------------------





# ------------- ПЕРЕХОД МЕЖДУ УРОВНЯМИ --------------
func play_transition_to_next_level() -> void:
	is_transitioning = true
	button_done.disabled = true

	transition_overlay.visible = true
	transition_overlay.modulate.a = 0.0
	transition_overlay.move_to_front()

	var tween := create_tween()

	tween.tween_property(transition_overlay, "modulate:a", 1.0, 0.18)
	tween.tween_callback(_switch_to_next_level_under_overlay)
	tween.tween_interval(0.03)
	tween.tween_property(transition_overlay, "modulate:a", 0.0, 0.18)

	await tween.finished

	button_done.disabled = false
	is_transitioning = false


func _switch_to_next_level_under_overlay() -> void:
	reset_answer_feedback()
	return_cards_to_base()

	current_task_index = randi_range(0, Global.FOURTH_MODE_TASKS.size() - 1)

	current_task = Global.FOURTH_MODE_TASKS[current_task_index]
	setup_level()


func return_cards_to_base() -> void:
	function_slot.instant_clear_slot()
	angle_slot.instant_clear_slot()
	value_slot.instant_clear_slot()

func update_counter() -> void:
	counter_label.text = "Счёт: " + str(counter_value)


func show_loss_screen() -> void:
	if loss_screen != null:
		return

	loss_screen = LOSS_SCREEN_SCENE.instantiate()
	$UI.add_child(loss_screen)

	loss_screen.set_anchors_preset(Control.PRESET_FULL_RECT)
	loss_screen.offset_left = 0
	loss_screen.offset_top = 0
	loss_screen.offset_right = 0
	loss_screen.offset_bottom = 0

	loss_screen.modulate.a = 0.0
	loss_screen.move_to_front()

	var tween := create_tween()
	tween.tween_property(loss_screen, "modulate:a", 1.0, 0.25)



# ---------------------------------------------------
