extends TextureRect

signal card_dropped(slot_type: String, card_value: String)

var slot_type: String = ""
var current_value: String = ""
var current_card: Control = null

const CARD_DEFAULT_TEXTURE := preload("res://textures/fourthMode/card.png")

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	add_to_group("fourth_slots")
	_parse_slot_name()


func _parse_slot_name() -> void:
	if name == "FunctionSlot":
		slot_type = "function"
	elif name == "AngleSlot":
		slot_type = "angle"
	elif name == "ValueSlot":
		slot_type = "value"
	else:
		push_warning("Unknown slot name: " + name)


func can_accept_card(incoming_card_type: String) -> bool:
	if not is_visible_in_tree():
		return false

	return incoming_card_type == slot_type


func place_card(source_card: Control) -> void:
	# Если в слоте уже лежит другая карточка,
	# сначала отправляем её обратно домой.
	if current_card != null and current_card != source_card:
		current_card.return_home()

	current_card = source_card
	current_value = str(source_card.card_value)

	source_card.move_to_slot(self)

	card_dropped.emit(slot_type, current_value)


func take_card(card: Control) -> void:
	if current_card != card:
		return

	current_card = null
	current_value = ""

	card_dropped.emit(slot_type, current_value)


func clear_slot() -> void:
	if current_card != null:
		current_card.return_home()

	current_card = null
	current_value = ""

	card_dropped.emit(slot_type, current_value)

func set_card_texture(new_texture: Texture2D) -> void:
	if current_card == null:
		return

	current_card.texture = new_texture


func reset_card_texture() -> void:
	if current_card == null:
		return

	current_card.texture = CARD_DEFAULT_TEXTURE

func instant_clear_slot() -> void:
	if current_card != null:
		current_card.instant_return_home()

	current_card = null
	current_value = ""

	card_dropped.emit(slot_type, current_value)
