extends Node2D

@onready var moving_objects = $Control/MovingObjects
@onready var text_edit = $Control/MovingObjects/TextEdit
@onready var no_sprite = $Control/MovingObjects/No

@export var max_speed: float = 80.0
@export var acceleration: float = 120.0
@export var yes_texture: Texture2D = preload("res://test_textures/mode2/YES.png")

var current_speed: float = 0.0
var is_moving: bool = false

func _ready() -> void:
	text_edit.editable = false

func _process(delta: float) -> void:
	if is_moving:
		current_speed = move_toward(current_speed, max_speed, acceleration * delta)
		moving_objects.position.x -= current_speed * delta

func _on_button_start_game_pressed() -> void:
	is_moving = true
	
	text_edit.editable = true
	text_edit.grab_focus()

func _on_text_edit_text_changed() -> void:
	if text_edit.text == "45":
		no_sprite.texture = yes_texture
