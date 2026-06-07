extends TextureRect

const EMPTY_CARD_TEXTURE := preload("res://textures/fourthMode/card_empty.png")
const CARD_DEFAULT_TEXTURE := preload("res://textures/fourthMode/card.png")
const SLOT_MAGNET_MARGIN := 70.0

var card_type: String = ""
var card_value: String = ""

var is_dragging: bool = false
var grab_offset: Vector2 = Vector2.ZERO

var home_parent: Node = null
var home_index: int = 0
var placeholder: TextureRect = null

var current_slot: Node = null

var drag_layer: Control = null
var move_tween: Tween = null


var card_default_size: Vector2 = Vector2.ZERO

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP

	home_parent = get_parent()
	home_index = get_index()

	card_default_size = size
	if card_default_size == Vector2.ZERO:
		card_default_size = custom_minimum_size

	_parse_card_name()
	_make_only_children_ignore_mouse(self)

	set_process(false)
	set_process_input(false)

func _parse_card_name() -> void:
	var parts := name.split("_", false, 1)

	if parts.size() < 2:
		push_warning("Wrong card name: " + name)
		return

	card_type = str(parts[0])
	card_value = str(parts[1])

	if card_type != "angle" and card_type != "function" and card_type != "value":
		push_warning("Unknown card type: " + name)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_start_drag()


func _input(event: InputEvent) -> void:
	if not is_dragging:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			_finish_drag()


func _process(_delta: float) -> void:
	if not is_dragging:
		return

	global_position = get_global_mouse_position() - grab_offset


func _start_drag() -> void:
	if card_type == "" or card_value == "":
		return

	if is_dragging:
		return

	if move_tween != null:
		move_tween.kill()
		move_tween = null

	is_dragging = true
	grab_offset = get_global_mouse_position() - global_position

	var old_global_position := global_position

	# Если карточка лежала в слоте, очищаем этот слот.
	if current_slot != null:
		current_slot.take_card(self)
		current_slot = null

	# Если карточка берётся из правого списка, запоминаем её место.
	# Если карточка уже была в слоте, home_parent и home_index остаются старыми.
	if placeholder == null:
		if get_parent() != drag_layer and current_slot == null:
			home_parent = get_parent()
			home_index = get_index()

		_create_placeholder()

	drag_layer = _get_drag_layer()
	reparent(drag_layer)

	_prepare_card_for_drag_layer()
	global_position = old_global_position
	z_index = 100

	set_process(true)
	set_process_input(true)


func _finish_drag() -> void:
	if not is_dragging:
		return

	is_dragging = false
	set_process(false)
	set_process_input(false)

	var target_slot := _find_slot_under_mouse()

	if target_slot != null:
		target_slot.place_card(self)
	else:
		return_home()


func move_to_slot(slot: Control) -> void:
	if move_tween != null:
		move_tween.kill()
		move_tween = null

	current_slot = slot

	move_tween = create_tween()
	move_tween.tween_property(self, "global_position", slot.global_position, 0.12)
	move_tween.tween_callback(Callable(self, "_put_into_slot").bind(slot))


func _put_into_slot(slot: Control) -> void:
	reparent(slot)

	set_anchors_preset(Control.PRESET_FULL_RECT)
	offset_left = 0
	offset_top = 0
	offset_right = 0
	offset_bottom = 0

	z_index = 0
	move_tween = null

	mouse_filter = Control.MOUSE_FILTER_STOP
	_make_only_children_ignore_mouse(self)


func return_home() -> void:
	if move_tween != null:
		move_tween.kill()
		move_tween = null

	if current_slot != null:
		current_slot.take_card(self)
		current_slot = null

	if placeholder == null:
		_create_placeholder()

	var target_position := placeholder.global_position

	move_tween = create_tween()
	move_tween.tween_property(self, "global_position", target_position, 0.18)
	move_tween.tween_callback(Callable(self, "_put_back_home"))


func _put_back_home() -> void:
	if placeholder == null or home_parent == null:
		return

	var insert_index := placeholder.get_index()

	placeholder.get_parent().remove_child(placeholder)
	placeholder.queue_free()
	placeholder = null

	reparent(home_parent)
	home_parent.move_child(self, insert_index)

	z_index = 0
	current_slot = null
	move_tween = null

	mouse_filter = Control.MOUSE_FILTER_STOP
	_make_only_children_ignore_mouse(self)


func _create_placeholder() -> void:
	if home_parent == null:
		return

	placeholder = TextureRect.new()
	placeholder.name = name + "_empty"
	placeholder.texture = EMPTY_CARD_TEXTURE

	placeholder.custom_minimum_size = custom_minimum_size
	placeholder.size_flags_horizontal = size_flags_horizontal
	placeholder.size_flags_vertical = size_flags_vertical
	placeholder.stretch_mode = stretch_mode
	placeholder.expand_mode = expand_mode
	placeholder.mouse_filter = Control.MOUSE_FILTER_IGNORE

	home_parent.add_child(placeholder)
	home_parent.move_child(placeholder, home_index)






func _find_slot_under_mouse() -> Node:
	var mouse_pos: Vector2 = get_global_mouse_position()
	var best_slot: Node = null
	var best_distance: float = INF

	for slot in get_tree().get_nodes_in_group("fourth_slots"):
		if not slot is Control:
			continue

		var slot_control := slot as Control

		if not slot_control.is_visible_in_tree():
			continue

		if not slot_control.has_method("can_accept_card"):
			continue

		if not slot_control.can_accept_card(card_type):
			continue

		var slot_rect := Rect2(slot_control.global_position, slot_control.size)
		var magnet_rect := slot_rect.grow(SLOT_MAGNET_MARGIN)

		if not magnet_rect.has_point(mouse_pos):
			continue

		var slot_center: Vector2 = slot_control.global_position + slot_control.size / 2.0
		var distance: float = mouse_pos.distance_to(slot_center)

		if distance < best_distance:
			best_distance = distance
			best_slot = slot_control

	return best_slot


func _get_drag_layer() -> Control:
	var scene := get_tree().current_scene
	var ui := scene.get_node_or_null("UI")

	if ui == null:
		ui = scene

	var existing_layer := ui.get_node_or_null("DragLayer")

	if existing_layer != null:
		return existing_layer

	var new_layer := Control.new()
	new_layer.name = "DragLayer"
	new_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE

	ui.add_child(new_layer)
	ui.move_child(new_layer, ui.get_child_count() - 1)

	new_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	new_layer.offset_left = 0
	new_layer.offset_top = 0
	new_layer.offset_right = 0
	new_layer.offset_bottom = 0

	return new_layer


func _prepare_card_for_drag_layer() -> void:
	# Когда карточка лежит в слоте, она растянута через FULL_RECT.
	# Перед свободным перетаскиванием нужно вернуть ей обычные якоря,
	# иначе внутренний Label начинает уезжать относительно экрана.
	set_anchors_preset(Control.PRESET_TOP_LEFT)

	offset_left = 0
	offset_top = 0
	offset_right = card_default_size.x
	offset_bottom = card_default_size.y

	size = card_default_size


func _make_only_children_ignore_mouse(node: Node) -> void:
	for child in node.get_children():
		_make_all_controls_ignore_mouse(child)


func _make_all_controls_ignore_mouse(node: Node) -> void:
	if node is Control:
		node.mouse_filter = Control.MOUSE_FILTER_IGNORE

	for child in node.get_children():
		_make_all_controls_ignore_mouse(child)




func instant_return_home() -> void:
	if move_tween != null:
		move_tween.kill()
		move_tween = null

	if current_slot != null:
		current_slot.take_card(self)
		current_slot = null

	if placeholder == null:
		_create_placeholder()

	_put_back_home()
