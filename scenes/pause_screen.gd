extends CanvasLayer

signal resume_pressed
signal restart_pressed
signal level_menu_pressed

@onready var background: ColorRect = $ColorRect2
@onready var panel: MarginContainer = $MarginContainer

var is_closing: bool = false
var settings_overlay_scene = preload("res://scenes/settings_overlay.tscn")
var current_settings_overlay = null

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

func _on_button_back_pressed() -> void:
	if current_settings_overlay != null:
		close_settings_overlay()
		return
	
	resume_pressed.emit()

func _on_button_level_menu_pressed() -> void:
	print("LEVEL MENU PRESSED")
	level_menu_pressed.emit()

func _on_button_settings_pressed() -> void:
	print("SETTINGS PRESSED")
	open_settings_overlay()

func open_settings_overlay() -> void:
	if current_settings_overlay != null:
		return
	
	current_settings_overlay = settings_overlay_scene.instantiate()
	add_child(current_settings_overlay)
	
	current_settings_overlay.back_pressed.connect(_on_settings_overlay_back_pressed)

func close_settings_overlay() -> void:
	if current_settings_overlay == null:
		return
	
	current_settings_overlay.close_overlay()
	current_settings_overlay = null

func _on_settings_overlay_back_pressed() -> void:
	close_settings_overlay()

func _on_button_restart_pressed() -> void:
	print("RESTART PRESSED")
	restart_pressed.emit()
