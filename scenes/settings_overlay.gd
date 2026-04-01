extends CanvasLayer

signal back_pressed

@onready var background: ColorRect = $ColorRect2
@onready var panel: MarginContainer = $MarginContainer
@onready var error: Control = $MarginContainer/Error

var is_closing: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
	if error != null:
		error.hide()
	
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

func close_overlay() -> void:
	queue_free()

func _on_button_back_pressed() -> void:
	back_pressed.emit()

func _on_button_error_pressed() -> void:
	if error != null:
		error.show()

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
