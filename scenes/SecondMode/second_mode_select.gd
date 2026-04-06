extends Control

@onready var button_normal = $VBoxContainer/RowMargin/ModesRow/ButtonNormalMode
@onready var button_endless = $VBoxContainer/RowMargin/ModesRow/ButtonEndlessMode

func _ready() -> void:
	update_mode_buttons()

#Обновляем и проверяем кнопки выбора режима
func update_mode_buttons() -> void:
	button_endless.disabled = not Global.second_mode_endless_unlocked
	
	if Global.second_mode_endless_unlocked:
		button_endless.modulate = Color(1, 1, 1, 1)
	else:
		button_endless.modulate = Color(0.6, 0.6, 0.6, 1)

#BACK button
func _on_button_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/modes_scene.tscn")

#NORMAL MODE button
func _on_button_normal_mode_pressed() -> void:
	Global.current_second_mode_type = "normal"
	get_tree().change_scene_to_file("res://scenes/second_mode.tscn")

#ENDLESS MODE button
func _on_button_endless_mode_pressed() -> void:
	if Global.second_mode_endless_unlocked:
		Global.current_second_mode_type = "endless"
		get_tree().change_scene_to_file("res://scenes/second_mode.tscn")
