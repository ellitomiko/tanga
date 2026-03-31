extends Control


@onready var error_overlay: Control = $Error

func _ready() -> void:
	error_overlay.hide()


func _on_button_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_button_error_pressed() -> void:
	error_overlay.show()


func _on_button_music_toggled(toggled_on: bool) -> void:
	if toggled_on:
		Global.set_music_enabled(false)
	else:
		Global.set_music_enabled(true)

func _on_button_sound_toggled(toggled_on: bool) -> void:
	if toggled_on:
		Global.set_sound_enabled(false)
	else:
		Global.set_sound_enabled(true)
