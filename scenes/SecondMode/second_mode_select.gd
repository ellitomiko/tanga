extends Control


const BUTTON_LABEL_PRESSED_OFFSET_Y := 28.0

@onready var button_normal: TextureButton = $ModesRow/ButtonNormalMode
@onready var button_endless: TextureButton = $ModesRow/ButtonEndlessMode

@onready var mode_buttons: Array[TextureButton] = [
	button_normal,
	button_endless
]

var button_label_offsets: Dictionary = {}


func _ready() -> void:
	_setup_button_label_press_effect()
	update_mode_buttons()


func _setup_button_label_press_effect() -> void:
	for button in mode_buttons:
		var label := button.get_node_or_null("Label") as Label
		
		if label == null:
			continue
		
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		button_label_offsets[button] = {
			"top": label.offset_top,
			"bottom": label.offset_bottom
		}
		
		button.button_down.connect(_on_mode_button_down.bind(button))
		button.button_up.connect(_on_mode_button_up.bind(button))
		button.mouse_exited.connect(_on_mode_button_up.bind(button))


func _on_mode_button_down(button: TextureButton) -> void:
	_set_button_label_pressed(button, true)


func _on_mode_button_up(button: TextureButton) -> void:
	_set_button_label_pressed(button, false)


func _set_button_label_pressed(button: TextureButton, is_pressed: bool) -> void:
	var label := button.get_node_or_null("Label") as Label
	
	if label == null:
		return
	
	if not button_label_offsets.has(button):
		return
	
	var saved_offsets: Dictionary = button_label_offsets[button]
	var offset_y := BUTTON_LABEL_PRESSED_OFFSET_Y if is_pressed else 0.0
	
	label.offset_top = saved_offsets["top"] + offset_y
	label.offset_bottom = saved_offsets["bottom"] + offset_y


# Обновляем и проверяем кнопки выбора режима
func update_mode_buttons() -> void:
	button_endless.disabled = not Global.second_mode_endless_unlocked
	
	if Global.second_mode_endless_unlocked:
		button_endless.modulate = Color(1, 1, 1, 1)
	else:
		button_endless.modulate = Color(0.895, 0.895, 0.895, 1.0)


# BACK button
func _on_button_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainUI/modes_scene.tscn")


# NORMAL MODE button
func _on_button_normal_mode_pressed() -> void:
	Global.current_second_mode_type = "normal"
	get_tree().change_scene_to_file("res://scenes/SecondMode/second_mode.tscn")


# ENDLESS MODE button
func _on_button_endless_mode_pressed() -> void:
	if Global.second_mode_endless_unlocked:
		Global.current_second_mode_type = "endless"
		get_tree().change_scene_to_file("res://scenes/SecondMode/second_mode.tscn")
