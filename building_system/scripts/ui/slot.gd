extends PanelContainer

@onready var _texture_rect: TextureRect = $MarginContainer/TextureRect
@onready var _label: Label = $Name

func _gui_input(event):
	if (
		event is InputEventMouseButton
		and event.button_index == MOUSE_BUTTON_LEFT
		and event.pressed
		):
		accept_event()
		BSEventBus.slot_clicked.emit(get_index(), event.button_index)

func set_slot_data(slot_data: BuildableResource):
	var new_size = ""
	match slot_data.snap_behaviour:
		BSEnums.SnapBehaviour.WALL:
			new_size = str(slot_data.size.x) + " x " + str(slot_data.size.y)
		BSEnums.SnapBehaviour.GROUND:
			new_size = str(slot_data.size.x) + " x " + str(slot_data.size.z)

	_texture_rect.texture = slot_data.texture_atlas if slot_data.texture_atlas else slot_data.texture_image
	tooltip_text = "%s\n%s" % [slot_data.name, slot_data.description]
	_label.text = "%s\n%s" % [slot_data.name, new_size]
