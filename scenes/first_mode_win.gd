extends CanvasLayer

signal restart_pressed
signal level_menu_pressed
signal next_level_pressed

@onready var background: ColorRect = $ColorRect
@onready var panel: MarginContainer = $MarginContainer

@onready var button_level_menu: TextureButton = $MarginContainer/HBoxContainer/ButtonLevelMenu
@onready var button_restart: TextureButton = $MarginContainer/HBoxContainer/ButtonRestart
@onready var button_next_level: TextureButton = $MarginContainer/HBoxContainer/ButtonNextLevel

var is_closing: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	animate_in()

func animate_in() -> void:
	if background != null:
		background.modulate.a = 0.0
	
	panel.scale = Vector2(0.9, 0.9)
	panel.modulate.a = 0.0
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	if background != null:
		tween.tween_property(background, "modulate:a", 1.0, 0.2)
	
	tween.tween_property(panel, "scale", Vector2.ONE, 0.22)
	tween.tween_property(panel, "modulate:a", 1.0, 0.22)

func animate_out_and_close() -> void:
	if is_closing:
		return
	
	is_closing = true
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	if background != null:
		tween.tween_property(background, "modulate:a", 0.0, 0.18)
	
	tween.tween_property(panel, "scale", Vector2(0.9, 0.9), 0.18)
	tween.tween_property(panel, "modulate:a", 0.0, 0.18)
	
	await tween.finished
	queue_free()

func _on_button_level_menu_pressed() -> void:
	level_menu_pressed.emit()

func _on_button_restart_pressed() -> void:
	restart_pressed.emit()

func _on_button_next_level_pressed() -> void:
	next_level_pressed.emit()
