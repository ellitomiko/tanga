extends Control


var first_play: bool = true

func _ready() -> void:
	Global.play_main_music()

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
