extends Control

func _ready() -> void:
	$FadeTransition/FadeTimer.start()
	$FadeTransition/AnimationPlayer.play('fade_out')


func _on_timer_timeout() -> void:
	$AnimationVideo.play()

func _on_animation_video_finished() -> void:
	get_tree().change_scene_to_file("res://scenes/MainUI/modes_scene.tscn")
