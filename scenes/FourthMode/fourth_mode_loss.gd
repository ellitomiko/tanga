extends Control

const MODES_SCENE := "res://scenes/MainUI/modes_scene.tscn"


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP


func _on_button_menu_pressed() -> void:
	get_tree().change_scene_to_file(MODES_SCENE)


func _on_button_restart_pressed() -> void:
	get_tree().reload_current_scene()	
