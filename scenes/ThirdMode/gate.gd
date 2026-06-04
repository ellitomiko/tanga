extends Node2D
class_name Mode3Gate

signal hit_player(gate: Mode3Gate)

const THIRD_MODE_TEXTURES_PATH := "res://textures/thirdMode/"

@onready var back_gate: Sprite2D = $BackGate
@onready var door: Sprite2D = $Door
@onready var front_gate: Sprite2D = $FrontGate
@onready var door_area: Area2D = $Door/Area2D
@onready var door_collision: CollisionShape2D = $Door/Area2D/CollisionShape2D

var function_name: String = "cos"
var is_door_opened: bool = false


func _ready() -> void:
	door_area.area_entered.connect(_on_door_area_entered)


func setup(new_function_name: String) -> void:
	function_name = new_function_name
	is_door_opened = false

	back_gate.texture = load(THIRD_MODE_TEXTURES_PATH + "passage_" + function_name + ".png")
	door.texture = load(THIRD_MODE_TEXTURES_PATH + "passage_" + function_name + "_door.png")
	front_gate.texture = load(THIRD_MODE_TEXTURES_PATH + "passage_" + function_name + "_front.png")

	door.visible = true
	door.modulate.a = 1.0
	door.scale = Vector2.ONE
	door_collision.set_deferred("disabled", false)


func _on_door_area_entered(area: Area2D) -> void:
	print("Gate поймал area: ", area.name, " groups: ", area.get_groups())

	if is_door_opened:
		print("Дверь уже открыта, столкновение игнорируется")
		return

	if area.is_in_group("tanga_hitbox"):
		print("Это HitBox мышки, отправляю hit_player")
		hit_player.emit(self)
	else:
		print("Это НЕ HitBox мышки")


func hide_door() -> void:
	break_door()


func break_door() -> void:
	if is_door_opened:
		return

	is_door_opened = true
	door_collision.set_deferred("disabled", true)

	var tween := create_tween()
	tween.set_parallel(true)

	tween.tween_property(
		door,
		"scale",
		Vector2(1.25, 1.25),
		0.18
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	tween.tween_property(
		door,
		"modulate:a",
		0.0,
		0.18
	)

	tween.finished.connect(func():
		door.visible = false
	)


#"res://scenes/MainUI/modes_scene.tscn"
