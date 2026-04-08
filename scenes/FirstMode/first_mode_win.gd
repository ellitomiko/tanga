extends CanvasLayer

signal restart_pressed
signal level_menu_pressed
signal next_level_pressed


@onready var button_level_menu: TextureButton = $MarginContainer/HBoxContainer/ButtonLevelMenu
@onready var button_restart: TextureButton = $MarginContainer/HBoxContainer/ButtonRestart
@onready var button_next_level: TextureButton = $MarginContainer/HBoxContainer/ButtonNextLevel

var is_closing: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED




func _on_button_level_menu_pressed() -> void:
	level_menu_pressed.emit()

func _on_button_restart_pressed() -> void:
	restart_pressed.emit()

func _on_button_next_level_pressed() -> void:
	next_level_pressed.emit()
