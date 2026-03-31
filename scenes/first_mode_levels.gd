extends Control

@onready var grid: GridContainer = $MarginContainer/VBoxContainer/GridMargin/GridContainer
@onready var button_prev = $MarginContainer/VBoxContainer/BottomBar/ButtonPrev
@onready var button_next = $MarginContainer/VBoxContainer/BottomBar/ButtonNext
const LEVEL_BUTTON_SCENE = preload('res://scenes/level_button.tscn')

var current_page: int = 0
var levels_per_page: int = 20

#BACK button
func _on_button_back_pressed() -> void:
	get_tree().change_scene_to_file('res://scenes/modes_scene.tscn')

func _ready() -> void:
	update_page()

#Апдейт страницы, отчищаем грид, ставим туда нужные кнопочки уровней, обновляем индексы у навигационных кнопок
func update_page() -> void:
	clear_grid()
	create_level_buttons()
	update_nav_buttons()

#Отчистка грида
func clear_grid() -> void:
	for child in grid.get_children():
		child.queue_free()

#Создаем нужное количество кнопочек уровня
func create_level_buttons() -> void:
	var start_index = current_page * levels_per_page
	var end_index = min(start_index + levels_per_page, Global.mode1levels_data.size())
	
	for i in range(start_index, end_index):
		var level_data = Global.mode1levels_data[i]
		
		var level_button = LEVEL_BUTTON_SCENE.instantiate()
		grid.add_child(level_button)
		
		level_button.setup(level_data)
		level_button.set_locked(is_level_locked(i))
		level_button.level_pressed.connect(_on_level_button_pressed)
		


#Проверка, закрыт ли уровень
func is_level_locked(index: int) -> bool:
	if index == 0:
		return false
	
	var previous_level = Global.mode1levels_data[index - 1]
	return not previous_level.get("done", false)


#Обновление прараметров навигационных кнопок внизу
func update_nav_buttons() -> void:
	var total_pages = int(ceil(float(Global.mode1levels_data.size()) / float(levels_per_page)))
	
	button_prev.visible = current_page > 0
	button_next.visible = current_page < total_pages - 1


#Перелистывание страницы назад
func _on_button_prev_pressed() -> void:
	if current_page > 0:
		current_page -= 1
		update_page()

#Перелистывание станицы вперед
func _on_button_next_pressed() -> void:
	var total_pages = int(ceil(float(Global.mode1levels_data.size()) / float(levels_per_page)))
	
	if current_page < total_pages - 1:
		current_page += 1
		update_page()

#Переход по кнопке уровня и передача туда информации об уровне
func _on_level_button_pressed(level_data: Dictionary) -> void:
	Global.current_mode1_level_data = level_data
	print("CLICK:", level_data)
	get_tree().change_scene_to_file('res://scenes/first_mode.tscn')
