extends Node3D
class_name BSGrid

var grid_cells = []

var _x_size = 200
var _z_size = 200
var _cell_size = 1.0
var _cell_height = 3.0
var _floor_layer_mask: int
var _wall_layer_mask: int

@onready var _grid_visual: MeshInstance3D = $GridVisual
@onready var _collision_shape_3D: CollisionShape3D = $GroundStaticBody3D/Ground
@onready var _ground: StaticBody3D = $GroundStaticBody3D

func initialize(
		x_size: int,
		z_size: int,
		cell_size: float,
		cell_height: float,
		ground_layer_mask: int,
		floor_layer_mask: int,
		wall_layer_mask: int):
	_x_size = x_size
	_z_size = z_size
	_cell_size = cell_size
	_cell_height = cell_height
	grid_cells = []
	for i in range(_x_size * _z_size):
		grid_cells.append(GridCell.new())
	_floor_layer_mask = floor_layer_mask
	_wall_layer_mask = wall_layer_mask
	_ground.collision_layer = ground_layer_mask

func set_active(is_active: bool):
	_collision_shape_3D.disabled = not is_active
	_grid_visual.visible = is_active

func get_cell_global_position(x: int, z: int) -> Vector3:
	return Vector3(x, 0, z) * _cell_size + global_position - Vector3(_x_size / 2.0, 0, _z_size / 2.0) + Vector3(_cell_size / 2.0, 0, _cell_size / 2.0)

func get_grid_position(global_grid_position: Vector3) -> Vector2:
	var x = floor((global_grid_position.x - global_position.x) / _cell_size) + _x_size / 2.0
	var z = floor((global_grid_position.z - global_position.z) / _cell_size) + _z_size / 2.0
	return Vector2(x, z)

func get_mouse_snapped_position(mouse_position: Vector3, mouse_object) -> Vector3:
	var x = round((mouse_position - global_position).x)
	var z = round((mouse_position - global_position).z)
	var x_offset = 0.0
	var z_offset = 0.0
	if mouse_object.has_x_offset or mouse_object.has_z_offset:
		if abs(mouse_object.get_y_rotation_in_degrees()) != 90.0:
			x_offset = _cell_size / 2 if mouse_object.has_x_offset else 0.0
			z_offset = _cell_size / 2 if mouse_object.has_z_offset else 0.0
		else:
			x_offset = _cell_size / 2 if mouse_object.has_z_offset else 0.0
			z_offset = _cell_size / 2 if mouse_object.has_x_offset else 0.0
		if x > (mouse_position - global_position).x:
			x_offset *= - 1
		if z > (mouse_position - global_position).z:
			z_offset *= 1
	return Vector3(x + x_offset, 0, z + z_offset) + global_position

func get_grid_cell(x: int, y: int) -> GridCell:
	if _is_valid_grid_index(x, y):
		var index = _get_grid_index_without_validation(x, y)
		return grid_cells[index]
	return null

func try_to_place_object(selected_object, y_rotation: float, last_snapped_position: Vector3):
	var x_length = selected_object.size.x if abs(y_rotation) != 90 else selected_object.size.z
	var z_length = selected_object.size.z if abs(y_rotation) != 90 else selected_object.size.x
	if x_length == 0:
		x_length = 1
	if z_length == 0:
		z_length = 1
	var grid_position = get_grid_position(last_snapped_position)
	var x_start = grid_position.x - x_length / 2
	var z_start = grid_position.y - z_length / 2
	for i in range(x_start, x_start + x_length):
		for j in range(z_start, z_start + z_length):
			var grid_cell = get_grid_cell(i, j)
			if selected_object.snap_behaviour == BSEnums.SnapBehaviour.GROUND and grid_cell.has_ground_object():
				return
			elif selected_object.snap_behaviour == BSEnums.SnapBehaviour.WALL:
				if abs(y_rotation) != 90:
					if grid_cell.has_wall_object(BSEnums.Side.MINUS_Z):
						return
				else:
					if grid_cell.has_wall_object(BSEnums.Side.MINUS_X):
						return
	var mask = _floor_layer_mask if selected_object.snap_behaviour == BSEnums.SnapBehaviour.GROUND else _wall_layer_mask
	var buildable_instance = BuildableInstance.new()
	add_child(buildable_instance)
	buildable_instance.initialize(selected_object, mask)
	buildable_instance.global_position = last_snapped_position
	buildable_instance.rotate_y(deg_to_rad(y_rotation))
	AnimationUtils.animate_placement(buildable_instance.object_instance)
	for i in range(x_start, x_start + x_length):
		for j in range(z_start, z_start + z_length):
			var grid_cell = get_grid_cell(i, j)
			if selected_object.snap_behaviour == BSEnums.SnapBehaviour.GROUND:
				grid_cell.set_ground_object(buildable_instance)
			elif selected_object.snap_behaviour == BSEnums.SnapBehaviour.WALL:
				if abs(y_rotation) != 90:
					grid_cell.set_wall_object(buildable_instance, BSEnums.Side.MINUS_Z)
				else:
					grid_cell.set_wall_object(buildable_instance, BSEnums.Side.MINUS_X)
			buildable_instance.add_cell(grid_cell)

func reset_grid():
	for cell in grid_cells:
		if cell.ground_object:
			cell.ground_object.clear_object()
		for wall in cell.wall_objects:
			if wall:
				wall.clear_object()
			
func _get_grid_index_without_validation(row, column):
	return (row * _z_size) + column
	
func _is_valid_grid_index(x: int, y: int) -> bool:
	return x <= _x_size and y <= _z_size and x > 0 and y > 0
