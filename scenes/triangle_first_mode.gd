extends Node2D

@onready var alfa: Sprite2D = $Alfa
@onready var beta: Sprite2D = $Beta

@onready var horizontal: Sprite2D = $Horizontal
@onready var vertical: Sprite2D = $Vertical
@onready var hypotenuse: Sprite2D = $Hypotenuse

@onready var vertical_block = $VerticalBlock
@onready var horizontal_block = $HorizontalBlock
@onready var hypotenuse_block = $HypotenuseBlock

const VERTICAL_ADJACENT = preload("res://test_textures/mode1/vertical_adjacent.png")
const VERTICAL_OPPOSITE = preload("res://test_textures/mode1/vertical_opposite.png")
const HORIZONTAL_ADJACENT = preload("res://test_textures/mode1/horizontal_adjacent.png")
const HORIZONTAL_OPPOSITE = preload("res://test_textures/mode1/horizontal_opposite.png")

func setup(angle: String, side_labels: Dictionary, solution: Dictionary) -> void:
	setup_angle(angle)
	setup_triangle_textures(angle)
	setup_blocks(side_labels, solution)

func setup_angle(angle: String) -> void:
	alfa.visible = angle == "alpha"
	beta.visible = angle == "beta"

func setup_triangle_textures(angle: String) -> void:
	match angle:
		"alpha":
			vertical.texture = VERTICAL_OPPOSITE
			horizontal.texture = HORIZONTAL_ADJACENT
		"beta":
			vertical.texture = VERTICAL_ADJACENT
			horizontal.texture = HORIZONTAL_OPPOSITE

func setup_blocks(side_labels: Dictionary, solution: Dictionary) -> void:
	vertical_block.setup(
		side_labels.get("vertical", ""),
		get_block_slot(side_labels.get("vertical", ""), solution)
	)
	
	horizontal_block.setup(
		side_labels.get("horizontal", ""),
		get_block_slot(side_labels.get("horizontal", ""), solution)
	)
	
	hypotenuse_block.setup(
		side_labels.get("hypotenuse", ""),
		get_block_slot(side_labels.get("hypotenuse", ""), solution)
	)

func get_block_slot(block_value: String, solution: Dictionary) -> String:
	var is_top = solution.get("top", "") == block_value
	var is_bottom = solution.get("bottom", "") == block_value
	
	if is_top and is_bottom:
		return "both"
	if is_top:
		return "top"
	if is_bottom:
		return "bottom"
	return "none"
