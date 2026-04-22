extends Node2D

@onready var angles_root = $RightSide/Angles
@onready var values_root = $RightSide/Values
@onready var equation_root = $UI/Equation
@onready var drag_layer = $DragLayer

var all_cards: Array[Control] = []
var all_covers: Array[Control] = []

var dragged_card: Control = null
var drag_offset: Vector2 = Vector2.ZERO

var start_parent: Control = null
var start_index: int = -1
var start_global_position: Vector2 = Vector2.ZERO
var placeholder: Control = null

var hovered_cover: Control = null


func _ready() -> void:
	all_cards.clear()
	all_covers.clear()

	_collect_cards(angles_root)
	_collect_cards(values_root)
	_collect_covers(equation_root)

	print("cards found: ", all_cards.size())
	print("covers found: ", all_covers.size())

	for card in all_cards:
		card.mouse_filter = Control.MOUSE_FILTER_STOP

	for cover in all_covers:
		cover.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(_delta: float) -> void:
	if dragged_card != null:
		dragged_card.global_position = get_viewport().get_mouse_position() - drag_offset
		hovered_cover = _find_cover_under_dragged_card()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_start_drag()
		else:
			_finish_drag()


func _start_drag() -> void:
	if dragged_card != null:
		return

	var clicked_card := _find_card_under_mouse()
	if clicked_card == null:
		print("card not found under mouse")
		return

	dragged_card = clicked_card
	start_parent = dragged_card.get_parent() as Control
	start_index = dragged_card.get_index()
	start_global_position = dragged_card.global_position
	drag_offset = get_viewport().get_mouse_position() - dragged_card.global_position

	placeholder = _make_placeholder(dragged_card)

	start_parent.remove_child(dragged_card)
	start_parent.add_child(placeholder)
	start_parent.move_child(placeholder, start_index)

	drag_layer.add_child(dragged_card)
	dragged_card.global_position = start_global_position

	print("drag start: ", dragged_card.name)


func _finish_drag() -> void:
	if dragged_card == null:
		return

	if hovered_cover != null:
		print("drop on: ", hovered_cover.name)
		_swap_with_cover(dragged_card, hovered_cover)
	else:
		print("drop failed")
		_return_to_start()

	dragged_card = null
	hovered_cover = null
	start_parent = null
	start_index = -1
	start_global_position = Vector2.ZERO
	placeholder = null


func _collect_cards(node: Node) -> void:
	for child in node.get_children():
		if child is Control and child.name.to_lower().begins_with("card_"):
			all_cards.append(child)
		_collect_cards(child)


func _collect_covers(node: Node) -> void:
	for child in node.get_children():
		if child is Control and child.name.ends_with("Cover"):
			all_covers.append(child)
		_collect_covers(child)


func _find_card_under_mouse() -> Control:
	var mouse_pos := get_viewport().get_mouse_position()

	for i in range(all_cards.size() - 1, -1, -1):
		var card := all_cards[i]
		if is_instance_valid(card) and card.visible:
			if card.get_global_rect().has_point(mouse_pos):
				return card

	return null


func _find_cover_under_dragged_card() -> Control:
	if dragged_card == null:
		return null

	var card_rect := dragged_card.get_global_rect()

	for cover in all_covers:
		if is_instance_valid(cover) and cover.visible:
			if card_rect.intersects(cover.get_global_rect()):
				return cover

	return null


func _make_placeholder(card: Control) -> Control:
	var p := ColorRect.new()
	p.color = Color(0, 0, 0, 0)
	p.custom_minimum_size = card.size
	p.size = card.size
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.name = "Placeholder"
	return p


func _swap_with_cover(card: Control, cover: Control) -> void:
	var cover_parent := cover.get_parent() as Control
	var cover_index := cover.get_index()
	var cover_global_position := cover.global_position

	print("=== SWAP START ===")
	print("card: ", card.name)
	print("cover: ", cover.name)
	print("start_parent: ", start_parent.name)
	print("cover_parent: ", cover_parent.name)
	print("card start global: ", start_global_position)
	print("cover start global: ", cover_global_position)
	print("cover size before: ", cover.size)
	print("cover min size before: ", cover.custom_minimum_size)

	cover_parent.remove_child(cover)

	if placeholder != null and is_instance_valid(placeholder):
		start_parent.remove_child(placeholder)

	start_parent.add_child(cover)
	start_parent.move_child(cover, start_index)

	drag_layer.remove_child(card)
	cover_parent.add_child(card)
	cover_parent.move_child(card, cover_index)

	# пробуем подогнать cover под размеры карточки
	cover.custom_minimum_size = card.size
	cover.size = card.size

	await get_tree().process_frame

	print("cover parent after: ", cover.get_parent().name)
	print("cover global after layout: ", cover.global_position)
	print("cover size after: ", cover.size)
	print("cover min size after: ", cover.custom_minimum_size)

	card.global_position = cover_global_position

	print("=== SWAP END ===")


func _return_to_start() -> void:
	drag_layer.remove_child(dragged_card)

	if placeholder != null and is_instance_valid(placeholder):
		start_parent.remove_child(placeholder)

	start_parent.add_child(dragged_card)
	start_parent.move_child(dragged_card, start_index)

	await get_tree().process_frame
	dragged_card.global_position = start_global_position

	print("returned: ", dragged_card.name)
