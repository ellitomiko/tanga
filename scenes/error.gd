extends Control

@onready var button_back: TextureButton = $ButtonBack
@onready var button_send: TextureButton = $ButtonSendRequest
@onready var text_edit: TextEdit = $TextEdit

func _ready() -> void:
	hide()

func open() -> void:
	text_edit.text = ""
	show()

func close() -> void:
	hide()


#CLOSE OVERLAY button
func _on_button_back_pressed() -> void:
	close()

#SEND button
func _on_button_send_request_pressed() -> void:
	var message := text_edit.text.strip_edges()
	
	if message.is_empty():
		print("Текст ошибки пустой")
		return
	
	print("Отправка ошибки: ", message)
	save_error_locally(message)
	text_edit.text = ""  # очистка поля перед след испольщование формы
	close()


#SAVE THE ERROR пока локально
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
