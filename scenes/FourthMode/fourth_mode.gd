extends Node2D

@onready var current_task_index: int = 6 -1
var current_task: Dictionary = {}


# ------------- ОТЛАДКА --------------
@onready var id_label: Label = $UI/Control/ID
@onready var type_label: Label = $UI/Control/Type
@onready var function_label: Label = $UI/Control/Function
@onready var angle_label: Label = $UI/Control/Angle
@onready var value_label: Label = $UI/Control/Value
# -------------------------------------

# ------------- ВЫРАЖЕНИЕ --------------
@onready var function_cover: TextureRect = $UI/Equation/FunctionCover
@onready var function_equation_label: Label = $UI/Equation/Function

@onready var angle_cover: TextureRect = $UI/Equation/AngleCover
@onready var angle_equation_label: Label = $UI/Equation/Angle

@onready var value_cover: TextureRect = $UI/Equation/ValueCover
# ---------------------------------------





func _ready() -> void:
	current_task = Global.FOURTH_MODE_TASKS[current_task_index]
	show_debug_task()
	setup_equation()


func show_debug_task() -> void:
	id_label.text = "ID: " + str(current_task["id"])
	type_label.text = "Type: " + str(current_task["format"])
	function_label.text = "Function: " + str(current_task["function"])
	angle_label.text = "Angle: " + str(current_task["angle"])
	value_label.text = "Value: " + str(current_task["value"])

func setup_equation() -> void:
	var task_format: String = str(current_task["format"])
	var task_function: String = str(current_task["function"])
	var task_angle: int = int(current_task["angle"])

	value_cover.visible = true

	if task_format == "FV":
		function_cover.visible = true
		function_equation_label.visible = false

		angle_cover.visible = false
		angle_equation_label.visible = true
		angle_equation_label.text = str(task_angle) + "°"

	elif task_format == "AV":
		function_cover.visible = false
		function_equation_label.visible = true
		function_equation_label.text = task_function

		angle_cover.visible = true
		angle_equation_label.visible = false
