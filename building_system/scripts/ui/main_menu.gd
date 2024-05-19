extends Control

@onready var _new_game: Button = $PanelContainer/MarginContainer/MainMenu/NewGameButton
@onready var _save_game: Button = $PanelContainer/MarginContainer/MainMenu/SaveButton
@onready var _load_game: Button = $PanelContainer/MarginContainer/MainMenu/LoadButton
@onready var _exit_game: Button = $PanelContainer/MarginContainer/MainMenu/ExitButton

func _ready():
	_new_game.pressed.connect(on_new_game_pressed)
	_save_game.pressed.connect(on_save_game_pressed)
	_load_game.pressed.connect(on_load_game_pressed)
	_exit_game.pressed.connect(on_exit_game_pressed)

func on_new_game_pressed():
	BSEventBus.new_game.emit()

func on_save_game_pressed():
	var save_files = SaveSystem.get_save_files_info()
	if len(save_files) > 0:
		BSEventBus.open_save_menu.emit()
	else:
		BSEventBus.save_game.emit(false)

func on_load_game_pressed():
	BSEventBus.open_load_menu.emit()

func on_exit_game_pressed():
	BSEventBus.game_exited.emit()
