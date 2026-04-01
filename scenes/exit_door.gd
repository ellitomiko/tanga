extends StaticBody2D

var is_open: bool = false
var is_animating: bool = false

@export var open_angle_degrees: float = 90.0
@export var open_duration: float = 1.4

var closed_rotation: float = 0.0
var opened_rotation: float = 0.0

var open_tween: Tween = null

func _ready() -> void:
	closed_rotation = rotation
	opened_rotation = closed_rotation + deg_to_rad(open_angle_degrees)

func open_exit() -> void:
	if is_open or is_animating:
		return
	
	is_animating = true
	
	if open_tween:
		open_tween.kill()
	
	open_tween = create_tween()
	open_tween.set_trans(Tween.TRANS_SINE)
	open_tween.set_ease(Tween.EASE_OUT)
	open_tween.tween_property(self, "rotation", opened_rotation, open_duration)
	open_tween.finished.connect(_on_open_finished)

func _on_open_finished() -> void:
	is_animating = false
	is_open = true
	open_tween = null
