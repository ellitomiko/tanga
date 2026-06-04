extends Control

const MODES_SCENE_PATH := "res://scenes/MainUI/modes_scene.tscn"


@onready var button_menu: TextureButton = $TextureRect2/HBoxContainer/ButtonMenu
@onready var button_restart: TextureButton = $TextureRect2/HBoxContainer/ButtonRestart


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _on_button_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(MODES_SCENE_PATH)


func _on_button_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
