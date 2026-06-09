extends Control


const BUTTON_LABEL_PRESSED_OFFSET_Y := 12.0

@onready var button_back: TextureButton = $ButtonBack
@onready var button_send: TextureButton = $TextureRect2/ButtonSendRequest
@onready var text_edit: TextEdit = $TextureRect2/TextureRect/TextEdit

var button_label_offsets: Dictionary = {}


func _ready() -> void:
	hide()
	_setup_button_label_press_effect()


func _setup_button_label_press_effect() -> void:
	var label := button_send.get_node_or_null("Label") as Label
	
	if label == null:
		return
	
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	button_label_offsets[button_send] = {
		"top": label.offset_top,
		"bottom": label.offset_bottom
	}
	
	button_send.button_down.connect(_on_text_button_down.bind(button_send))
	button_send.button_up.connect(_on_text_button_up.bind(button_send))
	button_send.mouse_exited.connect(_on_text_button_up.bind(button_send))


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


func open() -> void:
	text_edit.text = ""
	show()


func close() -> void:
	hide()


# CLOSE OVERLAY button
func _on_button_back_pressed() -> void:
	close()


# SEND button
func _on_button_send_request_pressed() -> void:
	var message := text_edit.text.strip_edges()
	
	if message.is_empty():
		print("Текст ошибки пустой")
		return
	
	print("Отправка ошибки: ", message)
	save_error_locally(message)
	text_edit.text = ""
	close()


# SAVE THE ERROR пока локально
func save_error_locally(message: String) -> void:
	var data := {
		"time": Time.get_datetime_string_from_system(),
		"text": message
	}
	
	var file := FileAccess.open("res://errors/error_reports.jsonl", FileAccess.WRITE_READ)
	if file == null:
		push_error("Не удалось открыть файл для записи")
		return
	
	file.seek_end()
	file.store_line(JSON.stringify(data))
	file.close()
	
	print("Ошибка сохранена локально")
