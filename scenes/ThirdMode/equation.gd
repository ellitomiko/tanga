extends Node2D
class_name Mode3Equation

signal answer_submitted(equation: Mode3Equation, text: String)

const THIRD_MODE_TEXTURES_PATH := "res://textures/thirdMode/"

const FORM_DEFAULT_TEXTURE := preload("res://textures/thirdMode/form.png")
const FORM_CORRECT_TEXTURE := preload("res://textures/thirdMode/form_correct.png")
const FORM_WRONG_TEXTURE := preload("res://textures/thirdMode/form_wrong.png")

const CORRECT_TEXT_COLOR := Color("#008D02")
const WRONG_TEXT_COLOR := Color("#BB0000")
const INPUT_RESULT_COLOR := Color("#FFFFFF")

@onready var function_label: Label = $HBoxContainer/Function
@onready var equal_label: Label = $HBoxContainer/Equal
@onready var angle_field: TextureRect = $HBoxContainer/AngleField
@onready var line_edit: LineEdit = $HBoxContainer/AngleField/LineEdit

# Если потом переименуешь TextureRect справа в ValueTexture,
# код тоже будет работать.
@onready var value_texture: TextureRect = _get_value_texture()

var equation_data: Dictionary = {}
var value_texture_file_name: String = ""


func _ready() -> void:
	_prepare_label_settings(function_label)
	_prepare_label_settings(equal_label)

	line_edit.editable = false
	line_edit.text_submitted.connect(_on_line_edit_text_submitted)


func setup(new_equation_data: Dictionary) -> void:
	equation_data = new_equation_data

	set_function(equation_data["function"])
	set_value_texture(equation_data["value"])
	reset_visual_state()


func focus_input(select_text: bool = false) -> void:
	line_edit.editable = true
	line_edit.focus_mode = Control.FOCUS_ALL
	line_edit.mouse_filter = Control.MOUSE_FILTER_STOP
	line_edit.grab_focus()

	if select_text:
		line_edit.select_all()


func disable_input() -> void:
	line_edit.release_focus()
	line_edit.focus_mode = Control.FOCUS_NONE
	line_edit.mouse_filter = Control.MOUSE_FILTER_IGNORE


func reset_visual_state() -> void:
	angle_field.texture = FORM_DEFAULT_TEXTURE

	_set_label_color(function_label, Color("#503AA6"))
	_set_label_color(equal_label, Color("#503AA6"))

	line_edit.text = ""
	line_edit.add_theme_color_override("font_color", Color("#503AA6"))

	if value_texture_file_name != "":
		set_value_texture(value_texture_file_name)


func show_correct() -> void:
	_set_label_color(function_label, CORRECT_TEXT_COLOR)
	_set_label_color(equal_label, CORRECT_TEXT_COLOR)

	angle_field.texture = FORM_CORRECT_TEXTURE
	line_edit.add_theme_color_override("font_color", INPUT_RESULT_COLOR)

	set_value_texture(_get_result_texture_name(value_texture_file_name, "_correct"))
	disable_input()


func show_wrong() -> void:
	_set_label_color(function_label, WRONG_TEXT_COLOR)
	_set_label_color(equal_label, WRONG_TEXT_COLOR)

	angle_field.texture = FORM_WRONG_TEXTURE
	line_edit.add_theme_color_override("font_color", INPUT_RESULT_COLOR)

	set_value_texture(_get_result_texture_name(value_texture_file_name, "_wrong"))

	line_edit.modulate = Color(1, 1, 1, 1)
	line_edit.self_modulate = Color(1, 1, 1, 1)

	disable_input()

func set_function(function_name: String) -> void:
	function_label.text = function_name


func set_value_texture(texture_file_name: String) -> void:
	value_texture_file_name = texture_file_name

	var texture_path := THIRD_MODE_TEXTURES_PATH + texture_file_name
	value_texture.texture = load(texture_path)


func _on_line_edit_text_submitted(new_text: String) -> void:
	answer_submitted.emit(self, new_text)


func _get_value_texture() -> TextureRect:
	var renamed_value := get_node_or_null("HBoxContainer/ValueTexture") as TextureRect

	if renamed_value != null:
		return renamed_value

	return $HBoxContainer/TextureRect


func _get_result_texture_name(texture_file_name: String, suffix: String) -> String:
	var dot_index := texture_file_name.rfind(".")

	if dot_index == -1:
		return texture_file_name + suffix

	var name_without_extension := texture_file_name.substr(0, dot_index)
	var extension := texture_file_name.substr(dot_index)

	return name_without_extension + suffix + extension


func _prepare_label_settings(label: Label) -> void:
	if label.label_settings != null:
		label.label_settings = label.label_settings.duplicate()


func _set_label_color(label: Label, color: Color) -> void:
	if label.label_settings != null:
		label.label_settings.font_color = color
	else:
		label.add_theme_color_override("font_color", color)
