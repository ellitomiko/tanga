extends Control


var first_play: bool = true


#START button
func _on_button_start_pressed() -> void:
	if first_play == false:
		first_play = true
		$FadeTransition.show()
		$FadeTransition/FadeTimer.start()
		$FadeTransition/AnimationPlayer.play('fade_in')
	else:
		get_tree().change_scene_to_file('res://scenes/MainUI/modes_scene.tscn')

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
