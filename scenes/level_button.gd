extends Control

signal level_pressed(level_data: Dictionary)

@onready var button_main: TextureButton = $ButtonMain
@onready var label_number: Label = $LabelNumber

var level_data: Dictionary = {}

#Принимаем информацию об уровне, берем id для числа (в последствии будет выводится не числом в лейбле,
#а подставляться в название текстуры - и нужная будет ставится
func setup(data: Dictionary) -> void:
	level_data = data
	label_number.text = str(level_data.get("id", 0))

#Блокируем уровень и отображаем это
func set_locked(is_locked: bool) -> void:
	button_main.disabled = is_locked
	
	if is_locked:
		modulate = Color(0.7, 0.7, 0.7, 1.0)
	else:
		modulate = Color(1, 1, 1, 1)

#Передаем сигнал от кнопки в пареметр, чтобы передать в другую сцену
func _on_button_main_pressed() -> void:
	level_pressed.emit(level_data)
