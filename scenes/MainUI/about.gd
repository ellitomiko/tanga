extends Control

#BACK button
func _on_button_back_pressed() -> void:
	get_tree().change_scene_to_file('res://scenes/MainUI/main_menu.tscn')
