extends Control
const BUTTON_LABEL_PRESSED_OFFSET_Y := 21.0

@onready var mode_buttons: Array[TextureButton] = [
	$GridContainer/ButtonFirst,
	$GridContainer/ButtonSecond,
	$GridContainer/ButtonThird,
	$GridContainer/ButtonFourth
]

var button_label_offsets: Dictionary = {}


func _ready() -> void:
	_setup_button_label_press_effect()


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


#BACK button
func _on_button_back_pressed() -> void:
	get_tree().change_scene_to_file('res://scenes/MainUI/main_menu.tscn')

#1MODE button
func _on_button_first_pressed() -> void:
	get_tree().change_scene_to_file('res://scenes/FirstMode/first_mode_levels.tscn')

#2MODE button
func _on_button_second_pressed() -> void:
	get_tree().change_scene_to_file('res://scenes/SecondMode/second_mode_select.tscn')

#3MODE button
func _on_button_third_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ThirdMode/third_mode.tscn")

#4MODE button
func _on_button_fourth_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/FourthMode/fourth_mode.tscn")
