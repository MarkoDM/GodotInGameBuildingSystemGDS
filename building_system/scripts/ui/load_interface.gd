extends Control

@onready var _item_list: ItemList = $PanelContainer/MarginContainer/VBoxContainer/ItemList
@onready var _load_button: Button = $PanelContainer/MarginContainer/VBoxContainer/Button
@onready var _close_button: Button = $PanelContainer/CloseButton

func _ready():
	BSEventBus.open_load_menu.connect(_on_open_load_menu)
	_item_list.item_activated.connect(_on_item_activated)
	_load_button.pressed.connect(_on_load_button_pressed)
	_close_button.pressed.connect(_on_close_button_pressed)

func _on_close_button_pressed():
	visible = false

func _on_load_button_pressed():
	var selected_items = _item_list.get_selected_items()
	if len(selected_items) > 0:
		var file_name = _item_list.get_item_text(selected_items[0])
		_load_game(file_name)

func _on_open_load_menu():
	_item_list.clear()
	var save_files = SaveSystem.get_save_files_info()
	for file in save_files:
		_item_list.add_item(file)
	visible = true

func _on_item_activated(index):
	var file_name = _item_list.get_item_text(index)
	_load_game(file_name)

func _load_game(file_name):
	BSEventBus.load_game.emit(file_name)
	BSEventBus.toggle_menu.emit()
	visible = false
