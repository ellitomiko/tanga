extends Control


signal level_pressed(level_data: Dictionary)


const BUTTON_LABEL_PRESSED_OFFSET_Y := 14.0

@onready var button_main: TextureButton = $ButtonMain
@onready var label_number: Label = $ButtonMain/LabelNumber

var level_data: Dictionary = {}

var label_default_offset_top: float
var label_default_offset_bottom: float


func _ready() -> void:
	label_number.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	label_default_offset_top = label_number.offset_top
	label_default_offset_bottom = label_number.offset_bottom
	
	button_main.button_down.connect(_on_button_main_down)
	button_main.button_up.connect(_on_button_main_up)
	button_main.mouse_exited.connect(_on_button_main_up)


# Принимаем информацию об уровне, берем id для числа
func setup(data: Dictionary) -> void:
	level_data = data
	label_number.text = str(level_data.get("id", 0))


# Блокируем уровень и отображаем это
func set_locked(is_locked: bool) -> void:
	button_main.disabled = is_locked
	
	if is_locked:
		modulate = Color(0.7, 0.7, 0.7, 1.0)
	else:
		modulate = Color(1, 1, 1, 1)


func _on_button_main_down() -> void:
	_set_label_pressed(true)


func _on_button_main_up() -> void:
	_set_label_pressed(false)


func _set_label_pressed(is_pressed: bool) -> void:
	var offset_y := BUTTON_LABEL_PRESSED_OFFSET_Y if is_pressed else 0.0
	
	label_number.offset_top = label_default_offset_top + offset_y
	label_number.offset_bottom = label_default_offset_bottom + offset_y


# Передаем сигнал от кнопки в параметр, чтобы передать в другую сцену
func _on_button_main_pressed() -> void:
	level_pressed.emit(level_data)
	get_tree().change_scene_to_file("res://scenes/FirstMode/first_mode.tscn")
