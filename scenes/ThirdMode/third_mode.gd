extends Node2D

const EQUATION_SCENE := preload("res://scenes/ThirdMode/equation.tscn")
const GATE_SCENE := preload("res://scenes/ThirdMode/gate.tscn")
const LOSS_SCENE := preload("res://scenes/ThirdMode/third_mode_loss.tscn")
const PAUSE_SCENE := preload("res://scenes/ThirdMode/third_mode_pause.tscn")
const WIN_SCENE := preload("res://scenes/ThirdMode/third_mode_win.tscn")

const START_BUTTON_LABEL_PRESSED_OFFSET_Y := 13.0
const START_BUTTON_LABEL_ACTIVE_COLOR := Color("#FFFFFF")

enum GameState {
	PRE_START,
	RUNNING,
	GAME_OVER,
	WIN
}

@onready var tanga_hitbox: Area2D = $Tanga/HitBox


@export var max_lives: int = 3
@export var tanga_fall_duration: float = 0.45
@export var tanga_blink_count: int = 3
@export var tanga_blink_duration: float = 0.1
@export var lost_heart_scale: Vector2 = Vector2(1.7, 1.7)
@export var lost_heart_duration: float = 0.22
@export var game_over_tanga_exit_x: float = -300.0

var lives: int = 3
var is_hit_reaction_running: bool = false
var loss_screen_shown: bool = false
var win_screen_shown: bool = false
var real_background_width: float = 1920.0

@onready var pause_button: TextureButton = $Control/ButtonPause

var pause_screen: Control = null

# --- Ноды ---

@onready var tanga: Node2D = $Tanga
@onready var cat: Node2D = $Cat

@onready var background: TileMapLayer = $MovingObjects/Background

@onready var start_button: TextureButton = $Control/ButtonStartGame
@onready var heart_container: TextureRect = $Control/HeartContainer
@onready var hearts_box: HBoxContainer = $Control/HeartContainer/HeartsBox


# --- Интро персонажей ---

@export var tanga_intro_start_x: float = -350.0
@export var cat_intro_start_x: float = -500.0

@export var tanga_intro_duration: float = 0.45
@export var cat_intro_duration: float = 0.5


# --- Скорости фона ---

@export var pre_start_speed: float = 520.0
@export var game_speed: float = 140.0
@export var speed_transition_duration: float = 2.4

var current_scroll_speed: float = 0.0
var speed_tween: Tween = null

# --- Усложнение скорости ---

@export var enable_speed_acceleration: bool = true

# Максимальная скорость, к которой постепенно стремится игра.
@export var max_game_speed: float = 320.0

# Чем больше число, тем быстрее скорость приближается к максимуму.
# 0.08-0.18 — нормальный диапазон.
@export var speed_acceleration_rate: float = 0.12

var is_speed_transition_running: bool = false

# --- Позиции персонажей после старта ---

@export var tanga_game_position: Vector2 = Vector2(507.0, 561.5)
@export var tanga_game_move_duration: float = 1.1

@export var cat_exit_position: Vector2 = Vector2(-650.0, 561.5)
@export var cat_exit_duration: float = 1.2


# --- Сердечки ---

@export var heart_container_start_y: float = -220.0
@export var heart_container_intro_duration: float = 0.35

@export var hearts_blink_count: int = 3
@export var hearts_blink_duration: float = 0.12


# --- Генерация уровней ---

@export var finish_background_function: String = "ctg"


@export var level_equation_y: float = 353.0
@export var level_equation_x_offset: float = 1000.0

@export var level_gate_y: float = 387.0
@export var level_gate_x_offset: float = -251.5 + 1920



# --- Фон ---

@export var background_width: float = 1920.0
@export var background_source_id: int = 0


# --- Состояние ---

var state: GameState = GameState.PRE_START

var tanga_target_position: Vector2
var cat_target_position: Vector2

var heart_container_target_position: Vector2

var intro_finished: bool = false
var is_generation_started: bool = false

var background_start_x: float = 0.0
var scroll_offset: float = 0.0

var hearts_blink_tween: Tween = null

var generated_objects_root: Node2D
var generated_objects: Array[Node2D] = []

var level_order: Array[int] = []
var active_levels: Array[Dictionary] = []

# До старта есть 2 cos-фона: cell 0 и cell 1.
# Первый игровой уровень ставится в cell 2.
var next_background_cell_x: int = 2

var location_tiles := {
	"cos": Vector2i(0, 0),
	"sin": Vector2i(1, 0),
	"tg": Vector2i(2, 0),
	"ctg": Vector2i(3, 0)
}

var current_location: String = "cos"

var start_button_label_offsets: Dictionary = {}
var start_button_label_normal_color: Color


func _ready() -> void:
	background_start_x = background.position.x
	current_scroll_speed = pre_start_speed

	generated_objects_root = Node2D.new()
	generated_objects_root.name = "GeneratedObjects"
	add_child(generated_objects_root)

	set_location("cos")
	setup_real_background_width()
	
	setup_tanga_hitbox()
	setup_progress_bar()

	setup_heart_container()
	_setup_start_button_label_effect()
	start_intro_animation()
	

func setup_real_background_width() -> void:
	var cell_0_global := background.to_global(background.map_to_local(Vector2i(0, 0)))
	var cell_1_global := background.to_global(background.map_to_local(Vector2i(1, 0)))

	real_background_width = abs(cell_1_global.x - cell_0_global.x)

	print("Реальная ширина фоновой клетки: ", real_background_width)

func _process(delta: float) -> void:
	match state:
		GameState.PRE_START:
			move_background_looped(current_scroll_speed, delta)

		GameState.RUNNING:
			update_speed_acceleration(delta)
			move_background_continuous(current_scroll_speed, delta)
			move_generated_objects(current_scroll_speed, delta)

		GameState.GAME_OVER:
			move_background_continuous(current_scroll_speed, delta)
			move_generated_objects(current_scroll_speed, delta)
			move_tanga_out_on_game_over(delta)
		
		GameState.WIN:
			pass


# --- Движение фона ---

func move_background_looped(speed: float, delta: float) -> void:
	scroll_offset += speed * delta

	if scroll_offset >= real_background_width:
		scroll_offset -= real_background_width

	background.position.x = background_start_x - scroll_offset


func move_background_continuous(speed: float, delta: float) -> void:
	background.position.x -= speed * delta


func move_generated_objects(speed: float, delta: float) -> void:
	for object in generated_objects:
		if is_instance_valid(object):
			object.position.x -= speed * delta


func start_speed_transition() -> void:
	if speed_tween != null:
		speed_tween.kill()

	is_speed_transition_running = true

	speed_tween = create_tween()

	speed_tween.tween_property(
		self,
		"current_scroll_speed",
		game_speed,
		speed_transition_duration
	).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)

	speed_tween.finished.connect(func():
		current_scroll_speed = game_speed
		is_speed_transition_running = false
	)

func update_speed_acceleration(delta: float) -> void:
	if not enable_speed_acceleration:
		return

	if is_speed_transition_running:
		return

	if current_scroll_speed >= max_game_speed:
		current_scroll_speed = max_game_speed
		return

	current_scroll_speed += (max_game_speed - current_scroll_speed) * speed_acceleration_rate * delta

	if current_scroll_speed > max_game_speed:
		current_scroll_speed = max_game_speed

# --- Фон и комнаты ---

func set_location(location_id: String) -> void:
	if not location_tiles.has(location_id):
		print("Нет такой локации: ", location_id)
		return

	current_location = location_id

	var atlas_coords: Vector2i = location_tiles[location_id]

	background.clear()

	# До старта крутятся два одинаковых cos-фона.
	background.set_cell(Vector2i(0, 0), background_source_id, atlas_coords)
	background.set_cell(Vector2i(1, 0), background_source_id, atlas_coords)

	next_background_cell_x = 2

	scroll_offset = 0.0
	background.position.x = background_start_x


func set_background_cell(cell_x: int, function_name: String) -> void:
	if not location_tiles.has(function_name):
		print("Нет фона для функции: ", function_name)
		return

	var atlas_coords: Vector2i = location_tiles[function_name]

	background.set_cell(
		Vector2i(cell_x, 0),
		background_source_id,
		atlas_coords
	)


func get_background_cell_global_x(cell_x: int) -> float:
	return background.global_position.x + real_background_width * cell_x


# --- Интро сердечек ---

func setup_heart_container() -> void:
	heart_container_target_position = heart_container.position

	heart_container.position = Vector2(
		heart_container_target_position.x,
		heart_container_start_y
	)

	heart_container.visible = false
	hearts_box.modulate.a = 0.0


func start_heart_container_intro() -> void:
	heart_container.visible = true

	var tween := create_tween()

	tween.tween_property(
		heart_container,
		"position",
		heart_container_target_position,
		heart_container_intro_duration
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	tween.finished.connect(_on_heart_container_intro_finished)


func _on_heart_container_intro_finished() -> void:
	heart_container.position = heart_container_target_position

	intro_finished = true

	start_hearts_blink_animation()


func start_hearts_blink_animation() -> void:
	if hearts_blink_tween != null:
		hearts_blink_tween.kill()

	hearts_blink_tween = create_tween()

	for i in range(hearts_blink_count):
		hearts_blink_tween.tween_callback(func():
			hearts_box.modulate.a = 1.0
		)

		hearts_blink_tween.tween_interval(hearts_blink_duration)

		hearts_blink_tween.tween_callback(func():
			hearts_box.modulate.a = 0.15
		)

		hearts_blink_tween.tween_interval(hearts_blink_duration)

	hearts_blink_tween.tween_callback(func():
		hearts_box.modulate.a = 1.0
	)


# --- Интро персонажей ---

func start_intro_animation() -> void:
	intro_finished = false

	tanga_target_position = tanga.position
	cat_target_position = cat.position

	tanga.position = Vector2(tanga_intro_start_x, tanga_target_position.y)
	cat.position = Vector2(cat_intro_start_x, cat_target_position.y)

	var tween := create_tween()

	# Первичный вылет на экран остаётся bouncy.
	tween.tween_property(
		tanga,
		"position",
		tanga_target_position,
		tanga_intro_duration
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	tween.tween_property(
		cat,
		"position",
		cat_target_position,
		cat_intro_duration
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	tween.finished.connect(_on_characters_intro_finished)


func _on_characters_intro_finished() -> void:
	tanga.position = tanga_target_position
	cat.position = cat_target_position

	start_heart_container_intro()


# --- Кнопка Start: смещение текста и цвет ---

func _setup_start_button_label_effect() -> void:
	var label := _get_start_button_label()

	if label == null:
		return

	label.mouse_filter = Control.MOUSE_FILTER_IGNORE

	start_button_label_offsets = {
		"top": label.offset_top,
		"bottom": label.offset_bottom
	}

	if label.label_settings != null:
		label.label_settings = label.label_settings.duplicate()
		start_button_label_normal_color = label.label_settings.font_color
	else:
		start_button_label_normal_color = label.get_theme_color("font_color")

	if not start_button.button_down.is_connected(_on_start_button_down):
		start_button.button_down.connect(_on_start_button_down)

	if not start_button.button_up.is_connected(_on_start_button_up):
		start_button.button_up.connect(_on_start_button_up)

	if not start_button.mouse_entered.is_connected(_on_start_button_mouse_entered):
		start_button.mouse_entered.connect(_on_start_button_mouse_entered)

	if not start_button.mouse_exited.is_connected(_on_start_button_mouse_exited):
		start_button.mouse_exited.connect(_on_start_button_mouse_exited)

	if not start_button.pressed.is_connected(_on_button_start_game_pressed):
		start_button.pressed.connect(_on_button_start_game_pressed)


func _get_start_button_label() -> Label:
	return start_button.get_node_or_null("Label") as Label


func _on_start_button_down() -> void:
	_set_start_button_label_pressed(true)
	_set_start_button_label_color(START_BUTTON_LABEL_ACTIVE_COLOR)


func _on_start_button_up() -> void:
	_set_start_button_label_pressed(false)

	if start_button.is_hovered():
		_set_start_button_label_color(START_BUTTON_LABEL_ACTIVE_COLOR)
	else:
		_set_start_button_label_color(start_button_label_normal_color)


func _on_start_button_mouse_entered() -> void:
	_set_start_button_label_color(START_BUTTON_LABEL_ACTIVE_COLOR)


func _on_start_button_mouse_exited() -> void:
	if not start_button.button_pressed:
		_set_start_button_label_pressed(false)
		_set_start_button_label_color(start_button_label_normal_color)


func _set_start_button_label_pressed(is_pressed: bool) -> void:
	var label := _get_start_button_label()

	if label == null:
		return

	if start_button_label_offsets.is_empty():
		return

	var offset_y := START_BUTTON_LABEL_PRESSED_OFFSET_Y if is_pressed else 0.0

	label.offset_top = start_button_label_offsets["top"] + offset_y
	label.offset_bottom = start_button_label_offsets["bottom"] + offset_y


func _set_start_button_label_color(color: Color) -> void:
	var label := _get_start_button_label()

	if label == null:
		return

	if label.label_settings != null:
		label.label_settings.font_color = color
	else:
		label.add_theme_color_override("font_color", color)


# --- Старт игры ---

func _on_button_start_game_pressed() -> void:
	if not intro_finished:
		return

	if is_generation_started:
		return

	is_generation_started = true
	start_button.visible = false

	if hearts_blink_tween != null:
		hearts_blink_tween.kill()
		hearts_blink_tween = null

	hearts_box.modulate.a = 1.0

	start_gameplay()


func start_gameplay() -> void:
	state = GameState.RUNNING

	prepare_level_order()
	generate_all_levels_from_order()

	focus_first_equation()

	start_speed_transition()
	move_characters_to_game_positions()



func move_characters_to_game_positions() -> void:
	var tween := create_tween()
	tween.set_parallel(true)

	# После старта мышка плавно переезжает на игровую позицию без bouncy.
	tween.tween_property(
		tanga,
		"position",
		tanga_game_position,
		tanga_game_move_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# Кошка плавно уезжает влево за экран без bouncy.
	var cat_target_exit_position := Vector2(cat_exit_position.x, cat.position.y)

	tween.tween_property(
		cat,
		"position",
		cat_target_exit_position,
		cat_exit_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


# --- Полная динамическая генерация уровней ---

func prepare_level_order() -> void:
	level_order.clear()

	# Первый уровень всегда ID = 1.
	if Global.mode3_equations_pool.has(1):
		level_order.append(1)
	else:
		print("В пуле нет стартового уровня ID = 1")

	# Все остальные уровни из пула идут в полном рандоме.
	var random_ids := Global.mode3_equations_pool.keys()
	random_ids.erase(1)
	random_ids.shuffle()

	for level_id in random_ids:
		level_order.append(level_id)

	print("Порядок уровней третьего режима: ", level_order)


func generate_all_levels_from_order() -> void:
	for level_id in level_order:
		generate_level_by_id(level_id)
	generate_finish_background()


func generate_level_by_id(level_id: int) -> void:
	if not Global.mode3_equations_pool.has(level_id):
		print("Нет выражения для третьего режима с ID: ", level_id)
		return

	var equation_data: Dictionary = Global.mode3_equations_pool[level_id]
	var function_name: String = equation_data["function"]

	var level_cell_x := next_background_cell_x

	set_background_cell(level_cell_x, function_name)

	var level_start_x := get_background_cell_global_x(level_cell_x)

	var equation := spawn_equation(equation_data, level_start_x)
	var gate := spawn_gate(function_name, level_start_x)

	active_levels.append({
		"id": level_id,
		"data": equation_data,
		"cell_x": level_cell_x,
		"function": function_name,
		"equation": equation,
		"gate": gate,
		"completed": false
	})

	next_background_cell_x += 1

	print("Сгенерирован уровень ID: ", level_id, " function: ", function_name)


func spawn_equation(equation_data: Dictionary, level_start_x: float) -> Mode3Equation:
	var equation := EQUATION_SCENE.instantiate() as Mode3Equation

	generated_objects_root.add_child(equation)
	generated_objects.append(equation)

	equation.position = Vector2(
		level_start_x + level_equation_x_offset,
		level_equation_y
	)

	equation.setup(equation_data)
	equation.answer_submitted.connect(_on_equation_answer_submitted)

	return equation

func spawn_gate(function_name: String, level_start_x: float) -> Mode3Gate:
	var gate := GATE_SCENE.instantiate() as Mode3Gate

	generated_objects_root.add_child(gate)
	generated_objects.append(gate)

	gate.position = Vector2(
		level_start_x + level_gate_x_offset,
		level_gate_y
	)

	gate.setup(function_name)
	gate.hit_player.connect(_on_gate_hit_player)

	return gate



func generate_finish_background() -> void:
	set_background_cell(next_background_cell_x, finish_background_function)

	print("Сгенерирован финальный пустой фон: ", finish_background_function, " cell: ", next_background_cell_x)

	next_background_cell_x += 1


func focus_first_equation() -> void:
	focus_next_uncompleted_equation()


func focus_next_uncompleted_equation() -> void:
	for level in active_levels:
		if level.get("completed", false):
			continue

		var equation := level.get("equation") as Mode3Equation

		if equation != null and is_instance_valid(equation):
			equation.focus_input()
			return


func _on_equation_answer_submitted(equation: Mode3Equation, text: String) -> void:
	if state != GameState.RUNNING:
		return

	var level_index := get_level_index_by_equation(equation)

	if level_index == -1:
		print("Не найден уровень для выражения")
		return

	var cleaned_text := text.strip_edges()

	if cleaned_text == "":
		equation.show_wrong()
		return

	if not cleaned_text.is_valid_int():
		equation.show_wrong()
		return

	var user_angle := int(cleaned_text)
	var equation_data: Dictionary = active_levels[level_index]["data"]

	if is_answer_correct(equation_data, user_angle):
		handle_correct_answer(level_index)
	else:
		handle_wrong_answer(level_index)


func handle_correct_answer(level_index: int) -> void:
	if active_levels[level_index].get("completed", false):
		return
	
	var level: Dictionary = active_levels[level_index]

	var equation := level["equation"] as Mode3Equation
	var gate := level["gate"] as Mode3Gate

	if equation != null and is_instance_valid(equation):
		equation.show_correct()

	if gate != null and is_instance_valid(gate):
		gate.hide_door()

	active_levels[level_index]["completed"] = true
	add_level_progress()

	focus_next_uncompleted_equation()

func handle_wrong_answer(level_index: int) -> void:
	var level: Dictionary = active_levels[level_index]

	var equation := level["equation"] as Mode3Equation

	if equation != null and is_instance_valid(equation):
		equation.show_wrong()


func get_level_index_by_equation(target_equation: Mode3Equation) -> int:
	for i in range(active_levels.size()):
		var equation := active_levels[i].get("equation") as Mode3Equation

		if equation == target_equation:
			return i

	return -1


func is_answer_correct(equation_data: Dictionary, user_angle: int) -> bool:
	var normalized_user_angle := normalize_angle(user_angle)

	for correct_angle in equation_data["angle"]:
		if normalize_angle(correct_angle) == normalized_user_angle:
			return true

	return false


func normalize_angle(angle: int) -> int:
	var result := angle % 360

	if result < 0:
		result += 360

	return result





















func setup_tanga_hitbox() -> void:
	tanga_hitbox.add_to_group("tanga_hitbox")
	tanga_hitbox.monitoring = true
	tanga_hitbox.monitorable = true


func setup_lives() -> void:
	lives = max_lives

	for heart in hearts_box.get_children():
		if heart is CanvasItem:
			heart.visible = true
			heart.modulate.a = 1.0
			heart.scale = Vector2.ONE


func _on_gate_hit_player(gate: Mode3Gate) -> void:
	if state != GameState.RUNNING:
		return

	if is_hit_reaction_running:
		return

	var level_index := get_level_index_by_gate(gate)

	if level_index == -1:
		return

	var level: Dictionary = active_levels[level_index]

	if level.get("completed", false):
		return

	handle_gate_collision(level_index)


func get_level_index_by_gate(target_gate: Mode3Gate) -> int:
	for i in range(active_levels.size()):
		var gate := active_levels[i].get("gate") as Mode3Gate

		if gate == target_gate:
			return i

	return -1

func handle_gate_collision(level_index: int) -> void:
	is_hit_reaction_running = true

	var level: Dictionary = active_levels[level_index]
	var gate := level["gate"] as Mode3Gate
	var equation := level["equation"] as Mode3Equation

	active_levels[level_index]["completed"] = true
	add_level_progress()

	if gate != null and is_instance_valid(gate):
		gate.break_door()

	if equation != null and is_instance_valid(equation):
		equation.disable_input()

	lose_life()

	play_tanga_hit_reaction()

	if state != GameState.GAME_OVER:
		focus_next_uncompleted_equation()



func play_tanga_hit_reaction() -> void:
	tanga.play("fall")

	await get_tree().create_timer(tanga_fall_duration).timeout

	if state == GameState.GAME_OVER:
		is_hit_reaction_running = false
		return

	tanga.play("run")
	await blink_tanga()

	is_hit_reaction_running = false

func blink_tanga() -> void:
	var tween := create_tween()

	for i in range(tanga_blink_count):
		tween.tween_property(tanga, "modulate:a", 0.25, tanga_blink_duration)
		tween.tween_property(tanga, "modulate:a", 1.0, tanga_blink_duration)

	await tween.finished
	tanga.modulate.a = 1.0

func lose_life() -> void:
	if lives <= 0:
		return

	var heart_index := lives - 1
	lives -= 1

	animate_lost_heart(heart_index)

	if lives <= 0:
		start_game_over()

func animate_lost_heart(heart_index: int) -> void:
	var hearts := hearts_box.get_children()

	if heart_index < 0 or heart_index >= hearts.size():
		return

	var heart := hearts[heart_index] as TextureRect

	if heart == null:
		return

	heart.pivot_offset = heart.size / 2.0

	var tween := create_tween()
	tween.set_parallel(true)

	tween.tween_property(
		heart,
		"scale",
		lost_heart_scale,
		lost_heart_duration
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	tween.tween_property(
		heart,
		"modulate:a",
		0.0,
		lost_heart_duration
	)

	tween.finished.connect(func():
		heart.visible = false
		heart.scale = Vector2.ONE
	)



func start_game_over() -> void:
	if state == GameState.GAME_OVER:
		return

	state = GameState.GAME_OVER
	loss_screen_shown = false
	

	disable_all_equation_inputs()

func disable_all_equation_inputs() -> void:
	for level in active_levels:
		var equation := level.get("equation") as Mode3Equation

		if equation != null and is_instance_valid(equation):
			equation.disable_input()


func move_tanga_out_on_game_over(delta: float) -> void:
	tanga.position.x -= current_scroll_speed * delta

	if tanga.position.x <= game_over_tanga_exit_x and not loss_screen_shown:
		show_loss_screen()

func show_loss_screen() -> void:
	if loss_screen_shown:
		return

	loss_screen_shown = true

	var loss_screen := LOSS_SCENE.instantiate()
	$Control.add_child(loss_screen)

	loss_screen.z_index = 100





func _on_button_pause_pressed() -> void:
	show_pause_screen()


func show_pause_screen() -> void:
	if pause_screen != null:
		return

	pause_screen = PAUSE_SCENE.instantiate() as Control
	pause_screen.process_mode = Node.PROCESS_MODE_ALWAYS

	$Control.add_child(pause_screen)
	pause_screen.z_index = 200

	if pause_screen.has_signal("resume_requested"):
		pause_screen.resume_requested.connect(resume_game)

	get_tree().paused = true


func resume_game() -> void:
	get_tree().paused = false

	if pause_screen != null and is_instance_valid(pause_screen):
		pause_screen.queue_free()

	pause_screen = null


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("exit"):
		if get_tree().paused:
			resume_game()
		else:
			show_pause_screen()

	if event.is_action_pressed("cheat"):
		use_cheat_correct_answer()

func use_cheat_correct_answer() -> void:
	if state != GameState.RUNNING:
		return

	for i in range(active_levels.size()):
		var level := active_levels[i]

		if level.get("completed", false):
			continue

		var equation := level.get("equation") as Mode3Equation

		if equation == null or not is_instance_valid(equation):
			continue

		var equation_data: Dictionary = level["data"]
		var correct_angles: Array = equation_data["angle"]

		if correct_angles.is_empty():
			return

		var cheat_answer := str(correct_angles[0])

		equation.focus_input()
		equation.line_edit.text = cheat_answer

		_on_equation_answer_submitted(equation, cheat_answer)
		return














@onready var progress_bar: TextureProgressBar = $Control/ProgressWidget/Bar
@onready var progress_point: TextureRect = $Control/ProgressWidget/Bar/Point

var completed_levels_count: int = 0
var progress_point_start_position: Vector2


func setup_progress_bar() -> void:
	completed_levels_count = 0

	progress_bar.min_value = 0
	progress_bar.max_value = 32
	progress_bar.value = 0

	progress_point_start_position = progress_point.position

	update_progress_point()


func add_level_progress() -> void:
	if state == GameState.WIN:
		return

	completed_levels_count += 1
	completed_levels_count = min(completed_levels_count, 32)

	progress_bar.value = completed_levels_count
	update_progress_point()

	print("Прогресс третьего режима: ", completed_levels_count, "/32")

	if completed_levels_count >= 32:
		start_win()


func update_progress_point() -> void:
	if progress_bar.max_value <= 0:
		return

	var progress := float(progress_bar.value) / float(progress_bar.max_value)

	progress_point.position = Vector2(
		progress_point_start_position.x + progress_bar.size.x * progress,
		progress_point_start_position.y
	)






















func start_win() -> void:
	if state == GameState.WIN:
		return

	state = GameState.WIN
	win_screen_shown = false

	disable_all_equation_inputs()
	show_win_screen()


func show_win_screen() -> void:
	if win_screen_shown:
		return

	win_screen_shown = true

	var win_screen := WIN_SCENE.instantiate()
	$Control.add_child(win_screen)

	win_screen.z_index = 100
