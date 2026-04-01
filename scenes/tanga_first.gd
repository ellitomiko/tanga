extends CharacterBody2D

var direction: Vector2 = Vector2.ZERO
var speed: int = 600

@onready var carry_marker: Marker2D = $CarryMarker

var carried_block = null
var current_target_block = null

func _ready() -> void:
	add_to_group("player")

func _physics_process(_delta: float) -> void:
	direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * speed
	move_and_slide()
	
	if direction != Vector2.ZERO:
		var target_rotation = direction.angle()
		rotation = lerp_angle(rotation, target_rotation, 0.2)
	
	update_target_block()
	
	var first_mode = get_first_mode()
	if first_mode != null:
		if carried_block != null:
			first_mode.update_slot_highlight(carried_block)
		else:
			first_mode.clear_slot_highlight()
	
	if Input.is_action_just_pressed("grab"):
		handle_grab()

func handle_grab() -> void:
	var first_mode = get_first_mode()
	
	# ЕСЛИ уже несём блок
	if carried_block != null:
		if first_mode != null and first_mode.try_place_block(carried_block):
			carried_block = null
			return
		
		drop_block_in_front()
		
		if first_mode != null:
			first_mode.clear_slot_highlight()
		
		carried_block = null
		return
	
	# ЕСЛИ руки пустые
	if current_target_block != null and current_target_block.can_be_picked():
		carried_block = current_target_block
		carried_block.pick_up(self)

func drop_block_in_front() -> void:
	if carried_block == null:
		return
	
	var drop_distance := 42.0
	var drop_dir := Vector2.RIGHT.rotated(rotation)
	var drop_pos = global_position + drop_dir * drop_distance
	
	carried_block.drop_to_world(drop_pos, rotation - deg_to_rad(90))

func find_nearest_available_block():
	var blocks = get_tree().get_nodes_in_group("pickup_blocks")
	var nearest = null
	var nearest_distance = INF
	
	for block in blocks:
		if not block.is_player_near:
			continue
		if block.is_carried:
			continue
		
		var dist = global_position.distance_to(block.global_position)
		if dist < nearest_distance:
			nearest_distance = dist
			nearest = block
	
	return nearest

func get_first_mode():
	return get_tree().get_first_node_in_group("first_mode")

func update_target_block() -> void:
	# Пока несём блок — никакие другие блоки не выделяются
	if carried_block != null:
		if current_target_block != null:
			current_target_block.set_active_target(false)
			current_target_block = null
		return
	
	var nearest_block = find_nearest_available_block()
	
	if current_target_block != nearest_block:
		if current_target_block != null:
			current_target_block.set_active_target(false)
		
		current_target_block = nearest_block
		
		if current_target_block != null:
			current_target_block.set_active_target(true)
