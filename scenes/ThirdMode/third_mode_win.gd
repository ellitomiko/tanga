extends Control

const MODES_SCENE_PATH := "res://scenes/MainUI/modes_scene.tscn"
const FOURTH_MODE := "res://scenes/FourthMode/fourth_mode.tscn"


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _on_button_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(MODES_SCENE_PATH)


func _on_button_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_button_next_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(FOURTH_MODE)
