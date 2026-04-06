extends Node2D

@onready var label_level_id: Label = $UI/InfoBox/LabelLevelId
@onready var label_kind: Label = $UI/InfoBox/LabelKind
@onready var label_angle: Label = $UI/InfoBox/LabelAngle
@onready var label_function: Label = $UI/InfoBox/LabelFunction
@onready var label_formula: Label = $UI/InfoBox/LabelFormula
@onready var label_mapping: Label = $UI/InfoBox/LabelMapping
@onready var label_solution: Label = $UI/InfoBox/LabelSolution
@onready var label_side_labels: Label = $UI/InfoBox/LabelSideLabels
@onready var triangle_holder: Node2D = $Objects/TriangleHolder
@onready var equation_left: Label = $Objects/EquationHolder/EquationLeft
@onready var equation_up_container: Label = $Objects/EquationHolder/EquationRight/UpContainer/EquationUpContainer
@onready var equation_down_container: Label = $Objects/EquationHolder/EquationRight/DownContainer/EquationDownContainer
@onready var top_slot: Area2D = $Objects/EquationHolder/EquationRight/UpContainer/Area2D
@onready var bottom_slot: Area2D = $Objects/EquationHolder/EquationRight/DownContainer/Area2D


@onready var top_slot_label: Label = $Objects/EquationHolder/EquationRight/UpContainer/EquationUpContainer
@onready var bottom_slot_label: Label = $Objects/EquationHolder/EquationRight/DownContainer/EquationDownContainer

@onready var top_slot_visual: CanvasItem = $Objects/EquationHolder/EquationRight/UpContainer
@onready var bottom_slot_visual: CanvasItem = $Objects/EquationHolder/EquationRight/DownContainer
@onready var exit_door: StaticBody2D = $Objects/ExitDoor
@onready var exit_area: Area2D = $Objects/ExitArea


const TRIANGLE_SCENE = preload('res://scenes/FirstMode/triangle_first_mode.tscn')

var current_level_data: Dictionary = {}
var current_triangle_labels: Dictionary = {}
var hint_visible: bool = false

var placed_top_block = null
var placed_bottom_block = null

var magnet_radius: float = 90.0
var current_slot_target: String = ""

var win_screen_scene = preload("res://scenes/FirstMode/first_mode_win.tscn")
var current_win_screen = null
var win_screen_shown: bool = false

var pause_screen_scene = preload('res://scenes/FirstMode/pause_screen.tscn')
var current_pause_screen = null

func _input(event):
	if event.is_action_pressed('exit'):
		if current_win_screen != null:
			return
		
		if current_pause_screen != null and current_pause_screen.current_settings_overlay != null:
			return
		
		toggle_pause()

func _ready() -> void:
	add_to_group("first_mode")
	
	current_level_data = Global.current_mode1_level_data
	show_level_data()
	setup_equation()
	create_level_view()
	exit_area.body_entered.connect(_on_exit_area_body_entered)

func _on_exit_area_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	
	if exit_door != null and not exit_door.is_open:
		return
	
	show_win_screen()



func _on_button_hint_pressed() -> void:
	hint_visible = not hint_visible
	update_equation_hint()

func show_level_data() -> void:
	var kind = current_level_data.get("kind", "")
	var task_data = current_level_data.get("task_data", {})
	var angle = task_data.get("angle", "")
	var func_name = task_data.get("func_name", "")
	
	label_level_id.text = "Уровень: " + str(current_level_data.get("id", 0))
	label_kind.text = "Вид: " + str(kind)
	label_angle.text = "Угол: " + str(angle)
	label_function.text = "Функция: " + str(func_name)
	
	if kind == "triangle":
		if current_triangle_labels.is_empty():
			current_triangle_labels = generate_triangle_side_labels()
		
		var triangle_data = build_triangle_context(func_name, angle, current_triangle_labels)
				
		label_formula.text = "Формула:\n" + dict_to_fraction(triangle_data["formula"])
		label_mapping.text = "Роли на сторонах:\n" + dict_to_string(triangle_data["layout"])
		label_side_labels.text = "Подписи сторон:\n" + dict_to_string(triangle_data["side_labels"])
		label_solution.text = "Ответ:\n" + dict_to_fraction(triangle_data["solution"])
	else:
		label_formula.text = "Формула:\n—"
		label_mapping.text = "Роли на сторонах:\n—"
		label_side_labels.text = "Подписи сторон:\n—"
		label_solution.text = "Ответ:\n—"


func create_level_view() -> void:
	var kind = current_level_data.get("kind", "")
	var task_data = current_level_data.get("task_data", {})
	var angle = task_data.get("angle", "")
	var func_name = task_data.get("func_name", "")
	
	match kind:
		"triangle":
			if current_triangle_labels.is_empty():
				current_triangle_labels = generate_triangle_side_labels()
			
			var triangle_data = build_triangle_context(func_name, angle, current_triangle_labels)
			create_triangle_view(angle, current_triangle_labels, triangle_data["solution"])
		
		"quarter":
			print("TODO quarter")
		
		"up_half":
			print("TODO up_half")
		
		"right_half":
			print("TODO right_half")
		
		"full_circle":
			print("TODO full_circle")
		
		_:
			push_error("Unknown level kind: " + str(kind))



func build_triangle_context(func_name: String, angle: String, side_labels: Dictionary) -> Dictionary:
	var formula = get_triangle_formula(func_name)
	var layout = get_triangle_role_layout(angle)
	var solution = build_triangle_solution(formula, layout, side_labels)
	
	return {
		"formula": formula,
		"layout": layout,
		"side_labels": side_labels,
		"solution": solution
	}

func get_triangle_formula(func_name: String) -> Dictionary:
	var formulas = {
		"sin": {"top": "opposite", "bottom": "hypotenuse"},
		"cos": {"top": "adjacent", "bottom": "hypotenuse"},
		"tg": {"top": "opposite", "bottom": "adjacent"},
		"ctg": {"top": "adjacent", "bottom": "opposite"}
	}
	return formulas.get(func_name, {})

func get_triangle_role_layout(angle: String) -> Dictionary:
	var layouts = {
		"alpha": {
			"vertical": "opposite",
			"horizontal": "adjacent",
			"hypotenuse": "hypotenuse"
		},
		"beta": {
			"vertical": "adjacent",
			"horizontal": "opposite",
			"hypotenuse": "hypotenuse"
		}
	}
	return layouts.get(angle, {})

func generate_triangle_side_labels() -> Dictionary:
	var labels = ["a", "b", "c"]
	labels.shuffle()
	
	return {
		"vertical": labels[0],
		"horizontal": labels[1],
		"hypotenuse": labels[2]
	}

func build_triangle_solution(formula: Dictionary, layout: Dictionary, side_labels: Dictionary) -> Dictionary:
	if formula.is_empty() or layout.is_empty() or side_labels.is_empty():
		return {}
	
	var role_to_side = {}
	for side_name in layout.keys():
		var role_name = layout[side_name]
		role_to_side[role_name] = side_name
	
	var top_role = formula.get("top", "")
	var bottom_role = formula.get("bottom", "")
	
	var top_side = role_to_side.get(top_role, "")
	var bottom_side = role_to_side.get(bottom_role, "")
	
	return {
		"top": side_labels.get(top_side, ""),
		"bottom": side_labels.get(bottom_side, "")
	}

func dict_to_fraction(data: Dictionary) -> String:
	if data.is_empty():
		return "—"
	return str(data.get("top", "?")) + " / " + str(data.get("bottom", "?"))

func dict_to_string(data: Dictionary) -> String:
	if data.is_empty():
		return "—"
	
	var result = ""
	for key in data.keys():
		result += str(key) + " → " + str(data[key]) + "\n"
	
	return result.strip_edges()

func create_triangle_view(angle: String, side_labels: Dictionary, solution: Dictionary) -> void:
	for child in triangle_holder.get_children():
		child.queue_free()
	
	var triangle = TRIANGLE_SCENE.instantiate()
	triangle_holder.add_child(triangle)
	
	triangle.setup(angle, side_labels, solution)


func setup_equation() -> void:
	var task_data = current_level_data.get("task_data", {})
	var func_name = task_data.get("func_name", "")
	var angle = task_data.get("angle", "")
	
	equation_left.text = build_equation_left_text(func_name, angle)
	hint_visible = false
	equation_up_container.text = "ответ"
	equation_down_container.text = "ответ"


func build_equation_left_text(func_name: String, angle: String) -> String:
	return func_name + " " + get_angle_symbol(angle) + " ="


func get_angle_symbol(angle: String) -> String:
	match angle:
		"alpha":
			return "α"
		"beta":
			return "β"
	return str(angle)


func update_equation_hint() -> void:
	if not hint_visible:
		equation_up_container.text = "ответ"
		equation_down_container.text = "ответ"
		return
	
	var task_data = current_level_data.get("task_data", {})
	var func_name = task_data.get("func_name", "")
	
	var formula = get_triangle_formula(func_name)
	
	var top = formula.get("top", "")
	var bottom = formula.get("bottom", "")
	
	equation_up_container.text = role_to_russian(top)
	equation_down_container.text = role_to_russian(bottom)


func role_to_russian(role: String) -> String:
	match role:
		"opposite":
			return "противолежащий катет"
		"adjacent":
			return "прилежащий катет"
		"hypotenuse":
			return "гипотенуза"
	return "ответ"


func check_answer() -> void:
	if placed_top_block == null or placed_bottom_block == null:
		return
	
	var correct = build_triangle_context(
		current_level_data.get("task_data", {}).get("func_name", ""),
		current_level_data.get("task_data", {}).get("angle", ""),
		current_triangle_labels
	)["solution"]
	
	var player_top = placed_top_block.block_value
	var player_bottom = placed_bottom_block.block_value
	
	if player_top == correct.get("top", "") and player_bottom == correct.get("bottom", ""):
		print("CORRECT ANSWER")
		
		if exit_door != null:
			exit_door.open_exit()
	else:
		print("WRONG ANSWER")


func try_place_block(block) -> bool:
	update_slot_highlight(block)
	
	if current_slot_target == "":
		clear_slot_highlight()
		return false
	
	place_block(block, current_slot_target)
	clear_slot_highlight()
	return true

func place_block(block, slot_type: String) -> void:
	var slot_node: Area2D = null
	var slot_position: Vector2
	var slot_rotation: float
	
	detach_block_from_slot(block)
	
	if slot_type == "top":
		slot_node = top_slot
		
		if placed_top_block != null and placed_top_block != block:
			return
		
		placed_top_block = block
	
	elif slot_type == "bottom":
		slot_node = bottom_slot
		
		if placed_bottom_block != null and placed_bottom_block != block:
			return
		
		placed_bottom_block = block
	
	else:
		return
	
	slot_position = slot_node.global_position
	slot_rotation = slot_node.global_rotation
	
	block.current_slot = slot_type
	block.is_carried = false
	block.carrier = null
	block.is_pickup_anim_playing = false
	block.z_index = 1
	
	# В контейнере коллизия выключена
	block.collision.disabled = true
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(block, "global_position", slot_position, 0.18)
	tween.tween_property(block, "rotation", slot_rotation, 0.18)
	
	check_answer()


func update_slot_highlight(carried_block) -> void:
	clear_slot_highlight()
	current_slot_target = ""
	
	if carried_block == null:
		return
	
	var check_pos = carried_block.global_position
	if carried_block.carrier != null:
		check_pos = carried_block.carrier.global_position
	
	var top_pos = top_slot.global_position
	var bottom_pos = bottom_slot.global_position
	
	var top_dist = check_pos.distance_to(top_pos)
	var bottom_dist = check_pos.distance_to(bottom_pos)
	
	var nearest_slot = ""
	var nearest_dist = INF
	
	if top_dist < nearest_dist and (placed_top_block == null or placed_top_block == carried_block):
		nearest_dist = top_dist
		nearest_slot = "top"
	
	if bottom_dist < nearest_dist and (placed_bottom_block == null or placed_bottom_block == carried_block):
		nearest_dist = bottom_dist
		nearest_slot = "bottom"
	
	if nearest_dist > magnet_radius:
		return
	
	current_slot_target = nearest_slot
	
	if nearest_slot == "top":
		highlight_top_slot()
	elif nearest_slot == "bottom":
		highlight_bottom_slot()

func detach_block_from_slot(block) -> void:
	if placed_top_block == block:
		placed_top_block = null
	
	if placed_bottom_block == block:
		placed_bottom_block = null
	
	block.current_slot = ""

func highlight_top_slot() -> void:
	top_slot_visual.modulate = Color(0.475, 0.29, 0.925, 1.0)
	bottom_slot_visual.modulate = Color(1.0, 1.0, 1.0, 1.0)

func highlight_bottom_slot() -> void:
	top_slot_visual.modulate = Color(1.0, 1.0, 1.0, 1.0)
	bottom_slot_visual.modulate = Color(1.0, 0.9, 0.35, 1.0)

func clear_slot_highlight() -> void:
	top_slot_visual.modulate = Color(1.0, 1.0, 1.0, 1.0)
	bottom_slot_visual.modulate = Color(1.0, 1.0, 1.0, 1.0)


func show_win_screen() -> void:
	if current_win_screen != null or win_screen_shown:
		return
	
	win_screen_shown = true
	
	var current_id = int(current_level_data.get("id", 0))
	if current_id > 0 and current_id <= Global.mode1levels_data.size():
		Global.mode1levels_data[current_id - 1]["done"] = true
	
	current_win_screen = win_screen_scene.instantiate()
	add_child(current_win_screen)
	
	current_win_screen.restart_pressed.connect(_on_win_restart_pressed)
	current_win_screen.level_menu_pressed.connect(_on_win_level_menu_pressed)
	current_win_screen.next_level_pressed.connect(_on_win_next_level_pressed)
	
	get_tree().paused = true

func _on_win_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_win_level_menu_pressed() -> void:
	get_tree().paused = false
	
	if current_win_screen != null:
		current_win_screen.queue_free()
		current_win_screen = null
	
	print("GO TO LEVEL MENU")
	get_tree().change_scene_to_file("res://scenes/FirstMode/first_mode_levels.tscn")
	# потом сюда поставим change_scene_to_file("res://....tscn")

func _on_win_next_level_pressed() -> void:
	go_to_next_mode1_level()
	# потом сюда поставим переход на следующий уровень

func go_to_next_mode1_level() -> void:
	var current_id = int(current_level_data.get("id", 0))
	
	if current_id <= 0:
		print("INVALID CURRENT LEVEL ID")
		return
	
	# текущий уровень отмечаем как done
	Global.mode1levels_data[current_id - 1]["done"] = true
	
	var next_id = current_id + 1
	
	# если следующего уровня нет
	if next_id > Global.mode1levels_data.size():
		print("NO NEXT LEVEL")
		return
	
	# передаём следующий уровень
	Global.current_mode1_level_data = Global.mode1levels_data[next_id - 1]
	
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/FirstMode/first_mode.tscn")


func toggle_pause() -> void:
	if current_pause_screen != null:
		close_pause()
	else:
		open_pause()

func open_pause() -> void:
	if current_pause_screen != null:
		return
	
	current_pause_screen = pause_screen_scene.instantiate()
	add_child(current_pause_screen)
	
	current_pause_screen.resume_pressed.connect(_on_pause_resume)
	current_pause_screen.restart_pressed.connect(_on_pause_restart)
	current_pause_screen.level_menu_pressed.connect(_on_pause_level_menu)

	
	get_tree().paused = true
	print("PAUSE OPENED")


func close_pause() -> void:
	if current_pause_screen == null:
		return
	
	current_pause_screen.queue_free()
	current_pause_screen = null
	
	get_tree().paused = false


func _on_pause_resume() -> void:
	#print("RESUME SIGNAL CAUGHT")
	close_pause()

func _on_pause_restart() -> void:
	#print("RESTART SIGNAL CAUGHT")
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_pause_level_menu() -> void:
	#print("LEVEL MENU SIGNAL CAUGHT")
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/FirstMode/first_mode_levels.tscn")

func _on_button_pause_pressed() -> void:
	open_pause()
