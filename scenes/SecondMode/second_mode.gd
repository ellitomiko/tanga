extends Node2D

@onready var button_back = $UI/HBoxContainer/ButtonBack
@onready var normal_mode_done = $UI/HBoxContainer/NormalModeDone

func _ready() -> void:
	setup_mode_ui()

func setup_mode_ui() -> void:
	if Global.current_second_mode_type == "normal":
		normal_mode_done.visible = true
	elif Global.current_second_mode_type == "endless":
		normal_mode_done.visible = false

func _on_button_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/SecondMode/second_mode_select.tscn")

func _on_normal_mode_done_pressed() -> void:
	Global.second_mode_endless_unlocked = true
	get_tree().change_scene_to_file("res://scenes/SecondMode/second_mode_select.tscn")
