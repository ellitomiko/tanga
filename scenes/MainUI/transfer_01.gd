extends Control

@onready var hint_label: Label = $Label

@onready var images: Array[TextureRect] = [
	$VBoxContainer/GridContainer/image1,
	$VBoxContainer/GridContainer/image2,
	$VBoxContainer/image3
]


var current_image_index: int = 0
var is_animating: bool = false


func _ready() -> void:
	Global.play_first_mode_music()

	for image in images:
		image.visible = false
		image.modulate.a = 0.0

	_start_label_blink()


func _start_label_blink() -> void:
	# Плавное бесконечное мигание Label
	var tween := create_tween()
	tween.set_loops()

	tween.tween_property(hint_label, "modulate:a", 0.25, 0.8)
	tween.tween_property(hint_label, "modulate:a", 1.0, 0.8)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_show_next_image()


func _show_next_image() -> void:
	if is_animating:
		return

	# Если все картинки уже показаны — следующий клик переводит дальше
	if current_image_index >= images.size():
		Global.current_mode1_level_data = Global.mode1levels_data[0]
		get_tree().change_scene_to_file("res://scenes/FirstMode/first_mode.tscn")
		return

	is_animating = true

	var image := images[current_image_index]
	image.visible = true
	image.modulate.a = 0.0

	var tween := create_tween()
	tween.tween_property(image, "modulate:a", 1.0, 0.8)

	await tween.finished

	current_image_index += 1
	is_animating = false
