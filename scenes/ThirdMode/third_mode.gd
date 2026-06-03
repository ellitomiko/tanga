extends Node2D

enum GameState {
	PRE_START,
	RUNNING
}

@onready var tanga: Node2D = $Tanga
@onready var cat: Node2D = $Cat

@onready var background: TileMapLayer = $MovingObjects/Background
@onready var start_button: TextureButton = $Control/ButtonStartGame

@onready var heart_container: TextureRect = $Control/HeartContainer
@onready var hearts_box: HBoxContainer = $Control/HeartContainer/HeartsBox

@export var tanga_intro_start_x: float = -350.0
@export var cat_intro_start_x: float = -500.0

@export var tanga_intro_duration: float = 0.75
@export var cat_intro_duration: float = 0.8

@export var heart_container_start_y: float = -220.0
@export var heart_container_intro_duration: float = 0.35

@export var hearts_blink_count: int = 3
@export var hearts_blink_duration: float = 0.12

@export var pre_start_speed: float = 400.0
@export var game_speed: float = 140.0

# Ширина одного фона в пикселях.
# Если один фон = 1920px по ширине, оставь 1920.
@export var background_width: float = 1920.0

# Обычно 0, если все фоны лежат в одном TileSet-атласе.
@export var background_source_id: int = 0

var state: GameState = GameState.PRE_START

var tanga_target_position: Vector2
var cat_target_position: Vector2

var heart_container_target_position: Vector2

var intro_finished: bool = false

var background_start_x: float = 0.0
var scroll_offset: float = 0.0

var hearts_blink_tween: Tween = null

var location_tiles := {
	"cos": Vector2i(0, 0),
	"sin": Vector2i(1, 0),
	"tg": Vector2i(2, 0),
	"ctg": Vector2i(3, 0)
}

var current_location: String = "cos"


func _ready() -> void:
	background_start_x = background.position.x
	set_location("cos")

	setup_heart_container()
	start_intro_animation()


func _process(delta: float) -> void:
	match state:
		GameState.PRE_START:
			move_background(pre_start_speed, delta)

		GameState.RUNNING:
			move_background(game_speed, delta)


func move_background(speed: float, delta: float) -> void:
	scroll_offset += speed * delta

	if scroll_offset >= background_width:
		scroll_offset -= background_width

	background.position.x = background_start_x - scroll_offset


func set_location(location_id: String) -> void:
	if not location_tiles.has(location_id):
		print("Нет такой локации: ", location_id)
		return

	current_location = location_id

	var atlas_coords: Vector2i = location_tiles[location_id]

	background.clear()

	# Два одинаковых фона рядом:
	# [cos][cos]
	# Когда первый уезжает влево, второй заходит справа.
	background.set_cell(Vector2i(0, 0), background_source_id, atlas_coords)
	background.set_cell(Vector2i(1, 0), background_source_id, atlas_coords)

	scroll_offset = 0.0
	background.position.x = background_start_x


func setup_heart_container() -> void:
	# Запоминаем финальную позицию, которую ты выставила руками в редакторе.
	heart_container_target_position = heart_container.position

	# Уводим контейнер вверх за экран.
	heart_container.position = Vector2(
		heart_container_target_position.x,
		heart_container_start_y
	)

	heart_container.visible = false

	# Сердечки сначала невидимые, чтобы потом они мигнули уже на контейнере.
	hearts_box.modulate.a = 0.0


func start_intro_animation() -> void:
	intro_finished = false
	start_button.disabled = true

	# Запоминаем позиции, которые ты выставила руками в редакторе.
	tanga_target_position = tanga.position
	cat_target_position = cat.position

	# Уводим персонажей влево за экран.
	tanga.position = Vector2(tanga_intro_start_x, tanga_target_position.y)
	cat.position = Vector2(cat_intro_start_x, cat_target_position.y)

	var tween := create_tween()

	# Сначала вылетает мышка.
	tween.tween_property(
		tanga,
		"position",
		tanga_target_position,
		tanga_intro_duration
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	# Потом вылетает кошка.
	tween.tween_property(
		cat,
		"position",
		cat_target_position,
		cat_intro_duration
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	tween.finished.connect(_on_characters_intro_finished)


func _on_characters_intro_finished() -> void:
	# На всякий случай жёстко возвращаем персонажей ровно в финальные позиции.
	tanga.position = tanga_target_position
	cat.position = cat_target_position

	start_heart_container_intro()


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

	# ВАЖНО:
	# после вылета контейнера кнопку уже можно нажимать,
	# даже если сердечки ещё мигают.
	intro_finished = true
	start_button.disabled = false

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


func _on_button_start_game_pressed() -> void:
	if not intro_finished:
		return

	if hearts_blink_tween != null:
		hearts_blink_tween.kill()
		hearts_blink_tween = null

	hearts_box.modulate.a = 1.0

	state = GameState.RUNNING
	start_button.visible = false
