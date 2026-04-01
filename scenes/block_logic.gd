extends StaticBody2D

var block_value: String = ""
var correct_slot: String = "none" # top / bottom / both / none

var is_carried: bool = false
var carrier: Node2D = null

var is_player_near: bool = false
var is_pickup_anim_playing: bool = false

var carry_distance_back: float = 42.0
var carry_height: float = 26.0
var carry_follow_speed: float = 14.0

var is_active_target: bool = false

var default_z_index: int = 3
var carried_z_index: int = 100

var current_slot: String = ""

@onready var sprite: Sprite2D = $Sprite2D
@onready var label: Label = $Label
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var pickup_area: Area2D = $Area2D

var highlight_tween: Tween = null
var pickup_tween: Tween = null

func _ready() -> void:
	add_to_group("pickup_blocks")
	default_z_index = z_index

	pickup_area.body_entered.connect(_on_pickup_area_body_entered)
	pickup_area.body_exited.connect(_on_pickup_area_body_exited)

func _process(delta: float) -> void:
	if is_carried and carrier != null and not is_pickup_anim_playing:
		var target_pos = get_carry_target_position()
		global_position = global_position.lerp(target_pos, carry_follow_speed * delta)
		
		var target_rot = get_carry_target_rotation()
		rotation = lerp_angle(rotation, target_rot, carry_follow_speed * delta)

func setup(value: String, slot: String) -> void:
	block_value = value
	correct_slot = slot
	label.text = value

func can_be_picked() -> bool:
	return is_player_near and is_active_target and not is_carried

func pick_up(new_carrier: Node2D) -> void:
	var first_mode = get_tree().get_first_node_in_group("first_mode")
	if first_mode != null:
		first_mode.detach_block_from_slot(self)
	
	is_carried = true
	carrier = new_carrier
	is_pickup_anim_playing = true
	z_index = carried_z_index
	
	stop_highlight()
	
	# пока блок в лапах — физическую коллизию выключаем
	collision.disabled = true
	
	var target_pos = get_carry_target_position()
	var target_rot = get_carry_target_rotation()
	
	if pickup_tween:
		pickup_tween.kill()
	
	pickup_tween = create_tween()
	pickup_tween.set_parallel(true)
	pickup_tween.tween_property(self, "global_position", target_pos, 0.22)
	pickup_tween.tween_property(self, "rotation", target_rot, 0.22)
	pickup_tween.finished.connect(_on_pickup_tween_finished)

func drop() -> void:
	is_carried = false
	carrier = null
	is_pickup_anim_playing = false
	z_index = default_z_index
	current_slot = ""
	
	if pickup_tween:
		pickup_tween.kill()
		pickup_tween = null
	
	collision.disabled = false
	refresh_highlight()

func drop_to_world(world_pos: Vector2, world_rot: float) -> void:
	is_carried = false
	carrier = null
	is_pickup_anim_playing = false
	z_index = default_z_index
	current_slot = ""
	
	if pickup_tween:
		pickup_tween.kill()
		pickup_tween = null
	
	global_position = world_pos
	rotation = world_rot
	collision.disabled = false
	refresh_highlight()

func get_carry_target_position() -> Vector2:
	if carrier == null:
		return global_position
	
	if carrier.has_node("CarryMarker"):
		return carrier.get_node("CarryMarker").global_position
	
	return carrier.global_position

func get_carry_target_rotation() -> float:
	if carrier == null:
		return rotation
	
	return carrier.rotation + deg_to_rad(90)

func start_highlight() -> void:
	if highlight_tween:
		highlight_tween.kill()
	
	sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)
	
	highlight_tween = create_tween()
	highlight_tween.set_loops()
	highlight_tween.tween_property(sprite, "modulate", Color(0.75, 0.45, 1.0, 1.0), 0.35)
	highlight_tween.tween_property(sprite, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.35)

func stop_highlight() -> void:
	if highlight_tween:
		highlight_tween.kill()
		highlight_tween = null
	
	sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)

func refresh_highlight() -> void:
	if is_carried:
		stop_highlight()
		return
	
	if is_player_near and is_active_target:
		start_highlight()
	else:
		stop_highlight()

func _on_pickup_tween_finished() -> void:
	is_pickup_anim_playing = false
	pickup_tween = null

func _on_pickup_area_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		is_player_near = true
		refresh_highlight()

func _on_pickup_area_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		is_player_near = false
		refresh_highlight()

func set_active_target(value: bool) -> void:
	is_active_target = value
	refresh_highlight()
