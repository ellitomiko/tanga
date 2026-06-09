extends Control


const BUTTON_LABEL_PRESSED_OFFSET_Y := 11.0

@onready var error_overlay: Control = $Error

@onready var text_buttons: Array[TextureButton] = [
	$TextureRect2/VBoxContainer/ButtonError
]

var button_label_offsets: Dictionary = {}


func _ready() -> void:
	error_overlay.hide()
	_setup_button_label_press_effect()


func _setup_button_label_press_effect() -> void:
	for button in text_buttons:
		var label := button.get_node_or_null("Label") as Label
		
		if label == null:
			continue
		
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		button_label_offsets[button] = {
			"top": label.offset_top,
			"bottom": label.offset_bottom
		}
		
		button.button_down.connect(_on_text_button_down.bind(button))
		button.button_up.connect(_on_text_button_up.bind(button))
		button.mouse_exited.connect(_on_text_button_up.bind(button))


func _on_text_button_down(button: TextureButton) -> void:
	_set_button_label_pressed(button, true)


func _on_text_button_up(button: TextureButton) -> void:
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


func _on_button_back_pressed() -> void:
	var target_scene = Global.settings_return_scene_path
	
	if target_scene == "":
		target_scene = "res://scenes/MainUI/main_menu.tscn"
	
	print(target_scene)
	get_tree().change_scene_to_file(target_scene)


func _on_button_error_pressed() -> void:
	error_overlay.show()


func _on_button_music_toggled(toggled_on: bool) -> void:
	if toggled_on:
		Global.set_music_enabled(false)
	else:
		Global.set_music_enabled(true)


func _on_button_sound_toggled(toggled_on: bool) -> void:
	if toggled_on:
		Global.set_sound_enabled(false)
	else:
		Global.set_sound_enabled(true)
