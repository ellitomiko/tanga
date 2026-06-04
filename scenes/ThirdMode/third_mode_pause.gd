extends Control

signal resume_requested

const MODES_SCENE_PATH := "res://scenes/MainUI/modes_scene.tscn"


@onready var button_menu: TextureButton = $TextureRect2/HBoxContainer/ButtonMenu
@onready var button_settings: TextureButton = $TextureRect2/HBoxContainer/ButtonSettings
@onready var button_restart: TextureButton = $TextureRect2/HBoxContainer/ButtonRestart

# У тебя эта кнопка сейчас называется TextureButton.
# Лучше потом переименовать её в ButtonBack или ButtonResume.
@onready var button_back: TextureButton = $ButtonBack


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _on_button_back_pressed() -> void:
	resume_requested.emit()


func _on_button_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(MODES_SCENE_PATH)
	


func _on_button_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_button_settings_pressed() -> void:
	print("Settings в паузе пока не подключены")
