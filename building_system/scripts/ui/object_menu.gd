extends Control

@onready var _slot: PackedScene = preload ("res://building_system/ui/slot.tscn")
@onready var _object_container: HBoxContainer = $PanelContainer/MarginContainer/ScrollContainer/HBoxContainer

func populate_object_grid(buildable_object_library: BuildableResourceLibrary):
	for child in _object_container.get_children():
		child.queue_free()
	for buildable_object in buildable_object_library.buildable_objects:
		var slot_instance = _slot.instantiate()
		_object_container.add_child(slot_instance)
		slot_instance.set_slot_data(buildable_object)
