extends Control

@onready var _level: Label = $PanelContainer/MarginContainer/GridContainer/LevelLabel
@onready var _build_mode: Label = $PanelContainer/MarginContainer/GridContainer/BuildModeLabel
@onready var _demolition_mode: Label = $PanelContainer/MarginContainer/GridContainer/DemolitionModeLabel

func _ready():
	BSEventBus.level_changed.connect(_on_level_changed)
	BSEventBus.build_mode_changed.connect(_on_build_mode_changed)
	BSEventBus.demolition_mode_changed.connect(_on_demolition_mode_changed)

func _on_level_changed(level):
	_level.text = str(level)

func _on_build_mode_changed(enabled):
	_build_mode.text = "on" if enabled else "off"

func _on_demolition_mode_changed(enabled):
	_demolition_mode.text = "on" if enabled else "off"
