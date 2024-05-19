extends Node3D
class_name MouseObject

var has_x_offset: bool
var has_z_offset: bool

var _mouse_node_child: Node3D
var _mouse_tiles: Array = []
var _tile_grid_visible: bool = false
var _layer_mask: int = BSConstants.DEFAULT_FLOOR_LAYER_MASK

@onready var _object_container: Node3D = $ObjectContainer
@onready var _grid_container: Node3D = $GridContainer
@onready var _mouse_tile = preload ("res://building_system/scenes/mouse_tile.tscn")

#var player_vars = get_node("/root/PlayerVariables")
func _ready():
	BSEventBus.mouse_tile_body_entered.connect(_on_mouse_tile_body_entered)
	BSEventBus.mouse_tile_body_exited.connect(_on_mouse_tile_body_exited)

func set_layer_mask(layer_mask: int):
	_layer_mask = layer_mask
	for tile in _mouse_tiles:
		tile.set_tile_layer_mask(layer_mask)

func update_visual(buildable_resource: BuildableResource):
	clear_mouse_object()
	var object_instance = buildable_resource.object_3d_model.instantiate()
	_object_container.add_child(object_instance)
	_mouse_node_child = object_instance
	has_x_offset = buildable_resource.size.x % 2 != 0
	has_z_offset = buildable_resource.size.z % 2 != 0
	create_tiles_grid(Vector2(buildable_resource.size.x, buildable_resource.size.z))

func clear_mouse_object():
	if _mouse_node_child:
		_mouse_node_child.queue_free()
	_mouse_node_child = null
	clear_grid()

func clear_grid():
	for child in _mouse_tiles:
		child.queue_free()
	_mouse_tiles = []
	reset_rotation(_grid_container)

func rotate_object(degrees):
	reset_rotation(_mouse_node_child)
	reset_rotation(_grid_container)
	_mouse_node_child.rotate_y(deg_to_rad(degrees))
	_grid_container.rotate_y(deg_to_rad(degrees))

func has_mouse_object() -> bool:
	return _mouse_node_child != null

func get_y_rotation_in_degrees() -> float:
	return _mouse_node_child.rotation_degrees.y

func get_y_rotation_in_rad() -> float:
	return _mouse_node_child.rotation.y
	
func is_colliding() -> bool:
	return _mouse_node_child and not _mouse_node_child.visible

func are_children_colliding() -> bool:
	for child in _mouse_tiles:
		if child.is_colliding():
			return true
	return false

func set_tile_grid_visible(are_tiles_visible: bool):
	for child in _mouse_tiles:
		child.set_visibility(are_tiles_visible)
	_tile_grid_visible = are_tiles_visible

func reset_rotation(node):
	node.transform.basis = Basis()

func create_tiles_grid(size, cell_size=1):
	var width = size.x * cell_size
	var height = size.y * cell_size
	for i in range(size.x):
		for j in range(size.y):
			var mouse_tile_instance = _mouse_tile.instantiate()
			_grid_container.add_child(mouse_tile_instance)
			mouse_tile_instance.set_tile_layer_mask(_layer_mask)
			if cell_size != BSConstants.DEFAULT_CELL_SIZE:
				mouse_tile_instance.set_size(cell_size)
			mouse_tile_instance.position = Vector3(i - width / 2.0 + cell_size / 2.0, 0.15, j - height / 2.0 + cell_size / 2.0)
			_mouse_tiles.append(mouse_tile_instance)

func _on_mouse_tile_body_entered():
	_mouse_node_child.visible = false
	if not _tile_grid_visible:
		set_tile_grid_visible(true)

func _on_mouse_tile_body_exited():
	if not are_children_colliding():
		if _mouse_node_child:
			_mouse_node_child.visible = true
		set_tile_grid_visible(false)
