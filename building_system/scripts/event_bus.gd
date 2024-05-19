extends Node
#class_name BSEventBus

# Signal emitted when a slot is clicked in the building menu.
signal slot_clicked(index, button)

# Signal emitted when the level is changed.
signal level_changed(level)

# Signal emitted when the build mode is changed.
signal build_mode_changed(enabled)

# Signal emitted when the demolition mode is changed.
signal demolition_mode_changed(enabled)

# Main menu signals

# Signal emitted when a new game is started.
signal new_game()

# Signal emitted when the game is saved.
signal save_game(overwrite)

# Signal emitted when a game is loaded.
signal load_game(filename)

# Signal emitted when the game is exited.
signal game_exited

# Signal emitted when the game menu is toggled.
signal toggle_menu

# Signal emitted when the load menu is opened.
signal open_load_menu

# Signal emitted when the save menu is opened.
signal open_save_menu

# Mouse node signals

# Signal emitted when the mouse enters a tile body.
signal mouse_tile_body_entered

# Signal emitted when the mouse exits a tile body.
signal mouse_tile_body_exited
