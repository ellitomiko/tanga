extends Node2D

@onready var label_level_id: Label = $UI/InfoBox/LabelLevelId
@onready var label_kind: Label = $UI/InfoBox/LabelKind
@onready var label_angle: Label = $UI/InfoBox/LabelAngle
@onready var label_function: Label = $UI/InfoBox/LabelFunction

func _ready() -> void:
	show_level_data()

#ИНФО о уровне проверяем всё ли подтягивается
func show_level_data() -> void:
	var level_data = Global.current_mode1_level_data
	
	label_level_id.text = "Уровень: " + str(level_data.get("id", 0))
	label_kind.text = "Вид: " + str(level_data.get("kind", ""))
	
	var task_data = level_data.get("task_data", {})
	label_angle.text = "Угол: " + str(task_data.get("angle", ""))
	label_function.text = "Функция: " + str(task_data.get("func_name", ""))

#BACK button
func _on_button_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/first_mode_levels.tscn")
