extends Control


var first_play: bool = true

const BUTTON_LABEL_PRESSED_OFFSET_Y := 13.0

@onready var menu_buttons: Array[TextureButton] = [
	$ButtonsBack/TextureRect/VBoxContainer/ButtonStart,
	$ButtonsBack/TextureRect/VBoxContainer/ButtonSettings,
	$ButtonsBack/TextureRect/VBoxContainer/ButtonAbout
]

var button_label_offsets: Dictionary = {}

func _ready() -> void:
	Global.play_main_music()
	_setup_button_label_press_effect()

#START button
func _on_button_start_pressed() -> void:
	if Global.first_start_pressed == false:
		Global.first_start_pressed = true
		get_tree().change_scene_to_file("res://scenes/MainUI/transfer_01.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/MainUI/modes_scene.tscn")

func _on_fade_timer_timeout() -> void:
	get_tree().change_scene_to_file('')


#SETTINGS button
func _on_button_settings_pressed() -> void:
		get_tree().change_scene_to_file('res://scenes/MainUI/settings.tscn')


#ABOUT button
func _on_button_about_pressed() -> void:
		get_tree().change_scene_to_file('res://scenes/MainUI/about.tscn')

#EXIT button
func _on_button_exit_pressed() -> void:
		get_tree().quit()
		
func _setup_button_label_press_effect() -> void:
	for button in menu_buttons:
		var label := button.get_node_or_null("Label") as Label
		
		if label == null:
			continue
		
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		button_label_offsets[button] = {
			"top": label.offset_top,
			"bottom": label.offset_bottom
		}
		
		button.button_down.connect(_on_menu_button_down.bind(button))
		button.button_up.connect(_on_menu_button_up.bind(button))
		button.mouse_exited.connect(_on_menu_button_up.bind(button))


func _on_menu_button_down(button: TextureButton) -> void:
	_set_button_label_pressed(button, true)


func _on_menu_button_up(button: TextureButton) -> void:
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
