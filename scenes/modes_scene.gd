extends Control

#BACK button
func _on_button_back_pressed() -> void:
	get_tree().change_scene_to_file('res://scenes/main_menu.tscn')

#1MODE button
func _on_button_first_pressed() -> void:
	get_tree().change_scene_to_file('res://scenes/first_mode_levels.tscn')

#2MODE button
func _on_button_second_pressed() -> void:
	get_tree().change_scene_to_file('res://scenes/second_mode_select.tscn')

#3MODE button
func _on_button_third_pressed() -> void:
	get_tree().change_scene_to_file('res://scenes/third_mode.tscn')

#4MODE button
func _on_button_fourth_pressed() -> void:
	get_tree().change_scene_to_file('res://scenes/fourth_mode.tscn')
