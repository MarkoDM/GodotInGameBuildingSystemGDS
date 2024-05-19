extends Control

@onready var _new_button: Button = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/New
@onready var _overwrite_button: Button = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Overwrite
@onready var _close_button: Button = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/CloseButton

func _ready():
	BSEventBus.open_save_menu.connect(_on_open_save_menu)
	_new_button.pressed.connect(_on_new_button_pressed)
	_overwrite_button.pressed.connect(_on_overwrite_button_pressed)
	_close_button.pressed.connect(_on_close_button_pressed)

func _on_open_save_menu():
	visible = true

func _on_new_button_pressed():
	BSEventBus.save_game.emit(false)
	visible = false

func _on_overwrite_button_pressed():
	BSEventBus.save_game.emit(true)
	visible = false

func _on_close_button_pressed():
	visible = false
