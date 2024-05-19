extends Node3D

@export var main_camera: Camera3D
@export var buildable_object_library: BuildableResourceLibrary
@export var cell_size = BSConstants.DEFAULT_CELL_SIZE
@export var cell_height = BSConstants.DEFAULT_CELL_HEIGHT
@export_flags_3d_physics var ground_layer_mask = BSConstants.DEFAULT_GROUND_LAYER_MASK
@export_flags_3d_physics var floor_layer_mask = BSConstants.DEFAULT_FLOOR_LAYER_MASK
@export_flags_3d_physics var wall_layer_mask = BSConstants.DEFAULT_WALL_LAYER_MASK
@export_flags_3d_physics var free_layer_mask = BSConstants.DEFAULT_FREE_LAYER_MASK
@export var x_size = BSConstants.DEFAULT_GRID_X_SIZE
@export var z_size = BSConstants.DEFAULT_GRID_Z_SIZE
@export var levels = BSConstants.DEFAULT_GRID_LEVELS
@export var drag_behavior = BSEnums.DragBehavior.INSTANT_PLACEMENT
@export var drag_threshold = BSConstants.DEFAULT_DRAG_THRESHOLD
@export var drag_visual_ground_offset = BSConstants.DEFAULT_DRAG_VISUAL_GROUND_OFFSET
@export var ground_mouse_visible: bool = false

var _demolish_layer_mask
var _free_objects_list = []
var _grids = []
var _active_grid
var _is_build_mode_active = false
var _is_demolish_mode_active = false
var _selected_object = null
var _current_mouse_position = Vector3.ZERO
var _last_snapped_position = Vector3.ZERO
var _is_mouse_pressed = false
var _current_rotation = 0
var _active_layer_mask
var _mouse_start_position = Vector3.ZERO
var _mouse_end_position = Vector3.ZERO
var _drag_rectangle_mesh
var _mouse_press_position = Vector2.ZERO
var _save_system
var _demolish_collider = null

@onready var _grid_container = $GridContainer
@onready var _free_objects_container = $FreeObjectsContainer
@onready var _ground_mouse_node = $GroundMouseDebug
@onready var _mouse_object: MouseObject = $MouseObject
@onready var _object_menu = $UI/ObjectInterface
@onready var _main_menu = $UI/MainMenuInterface
@onready var _grid_scene: PackedScene = preload ("res://building_system/scenes/building_system_grid.tscn")

func _ready():
	BSUtils.register_input_actions()
	_drag_rectangle_mesh = null
	_demolish_layer_mask = floor_layer_mask|wall_layer_mask|free_layer_mask
	_active_layer_mask = ground_layer_mask

	_object_menu.populate_object_grid(buildable_object_library)

	BSEventBus.slot_clicked.connect(on_object_menu_interact)
	BSEventBus.new_game.connect(_on_new_game_event)
	BSEventBus.save_game.connect(_save)
	BSEventBus.load_game.connect(_load)
	BSEventBus.game_exited.connect(on_exit_game_event)
	BSEventBus.toggle_menu.connect(toggle_pause_game)

	for i in range(levels):
		var grid_instance = _grid_scene.instantiate()
		_grid_container.add_child(grid_instance)
		grid_instance.initialize(x_size, z_size, cell_size, cell_height, ground_layer_mask, floor_layer_mask, wall_layer_mask)
		grid_instance.name = "Level" + str(i)
		var pos = Vector3(0, i * cell_height, 0)
		grid_instance.global_position = pos
		_grids.append(grid_instance)

	_active_grid = _grids[0]
	_active_grid.set_active(true)
	_save_system = BSSaveSystem.new()
	_ground_mouse_node.visible = ground_mouse_visible

func _physics_process(delta):
	if not _main_menu.visible and (_is_build_mode_active or _is_demolish_mode_active):
		var space_state = get_world_3d().direct_space_state
		var mouse_pos = get_viewport().get_mouse_position()
		var origin = main_camera.project_ray_origin(mouse_pos)
		var end = origin + main_camera.project_ray_normal(mouse_pos) * 999.0
		var query = PhysicsRayQueryParameters3D.new()
		query.from = origin
		query.to = end
		query.collide_with_bodies = true
		query.collide_with_areas = false
		query.collision_mask = _active_layer_mask
		var result = space_state.intersect_ray(query)
		if result.size() > 0:
			_current_mouse_position = result.position
			if _active_layer_mask == _demolish_layer_mask:
				if is_instance_valid(_demolish_collider):
					_demolish_collider.get_parent().set_demolition_view(false)
				_demolish_collider = result.collider
				_demolish_collider.get_parent().set_demolition_view(true)
			elif _active_layer_mask == ground_layer_mask:
				update_mouse_object_visual(delta)

func _input(event):
	if event.is_action_pressed("toggle_menu"):
		toggle_pause_game()
	if event.is_action_pressed("build_mode"):
		set_build_mode(not _is_build_mode_active)
	if event.is_action_pressed("demolish"):
		set_demolition_mode(not _is_demolish_mode_active)
		if _is_demolish_mode_active and _selected_object:
			_selected_object = null
			clear_mouse_object()

	if not _main_menu.visible:
		handle_grid_level_change_event(event)
		handle_object_rotation_event(event)
		handle_cancel_event(event)

func _unhandled_input(event: InputEvent) -> void:
	if not _main_menu.visible:
		handle_object_placement_event(event)
		handle_object_demolish_event(event)
		
func handle_grid_level_change_event(event):
	if event.is_action_pressed("grid_level_up") or event.is_action_pressed("grid_level_down"):
		_active_grid.set_active(false)
		var grids_size = _grids.size()
		var modifier = 1 if event.is_action_pressed("grid_level_up") else - 1
		var next_selected_grid_index = _grids.find(_active_grid) + modifier
		if next_selected_grid_index < 0:
			next_selected_grid_index = grids_size - 1
		elif next_selected_grid_index > grids_size - 1:
			next_selected_grid_index = 0
		_active_grid.set_active(false)
		_active_grid = _grids[next_selected_grid_index]
		_active_grid.set_active(true)
		var camera = main_camera.get_parent() if main_camera.get_parent() is CameraController else main_camera
		var new_camera_position = Vector3(camera.global_position.x, _active_grid.global_position.y, camera.global_position.z)
		camera.global_position = new_camera_position
		BSEventBus.level_changed.emit(next_selected_grid_index)

func handle_object_rotation_event(event):
	if event.is_action_pressed("rotate_object") and _mouse_object.has_mouse_object():
		_current_rotation = (_current_rotation + 90) % 360
		_mouse_object.rotate_object(_current_rotation)

func handle_cancel_event(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed and _selected_object:
		_selected_object = null
		clear_mouse_object()

func handle_object_placement_event(event):
	if _selected_object == null or _is_demolish_mode_active:
		return

	if event is InputEventMouseButton:
		var mouse_event = event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT:
			if mouse_event.pressed:
				if drag_behavior == BSEnums.DragBehavior.NONE:
					try_to_place_object()
				else:
					_is_mouse_pressed = true
					_mouse_press_position = mouse_event.position
					if drag_behavior == BSEnums.DragBehavior.DELAYED_PLACEMENT:
						_mouse_start_position = BSUtils.get_raycast_point(
							mouse_event.position,
							get_world_3d(),
							main_camera, 
							_active_layer_mask)
			else:
				# Mouse button released
				if _is_mouse_pressed:
					if _mouse_press_position.distance_to(mouse_event.position) < drag_threshold:
						# The mouse was not moved beyond the threshold, treat it as a click
						if drag_behavior == BSEnums.DragBehavior.INSTANT_PLACEMENT:
							try_to_place_object()
					if drag_behavior == BSEnums.DragBehavior.DELAYED_PLACEMENT:
						complete_delayed_drag()
					_is_mouse_pressed = false
	elif event is InputEventMouseMotion:
		var mouse_motion = event as InputEventMouseMotion
		if _is_mouse_pressed and drag_behavior != BSEnums.DragBehavior.NONE:
			if _mouse_press_position.distance_to(mouse_motion.position) >= drag_threshold:
				# Mouse moved beyond the threshold, treat it as a drag
				if drag_behavior == BSEnums.DragBehavior.INSTANT_PLACEMENT:
					try_to_place_object()
				else:
					# Update end position and redraw
					_mouse_end_position = BSUtils.get_raycast_point(
						mouse_motion.position, 
						get_world_3d(), 
						main_camera, 
						_active_layer_mask)
					on_drag_delayed()

func handle_object_demolish_event(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and _is_demolish_mode_active and _demolish_collider:
		var main_node = _demolish_collider.get_parent() as BuildableInstance
		main_node.clear_object()

func try_to_place_object():
	if _selected_object:
		if _selected_object.snap_behaviour != BSEnums.SnapBehaviour.FREE:
			_active_grid.try_to_place_object(_selected_object, _mouse_object.get_y_rotation_in_degrees(), _last_snapped_position)
		else:
			var buildable_instance = BuildableInstance.new()
			_free_objects_container.add_child(buildable_instance)
			buildable_instance.initialize(_selected_object, get_layer_mask(_selected_object.snap_behaviour))
			_free_objects_list.append(buildable_instance)
			buildable_instance.global_position = Vector3(_current_mouse_position.x, _active_grid.global_position.y, _current_mouse_position.z)
			buildable_instance.rotate_y(_mouse_object.get_y_rotation_in_rad())
			AnimationUtils.animate_placement(buildable_instance.object_instance)

func get_layer_mask(type: BSEnums.SnapBehaviour) -> int:
	match type:
		BSEnums.SnapBehaviour.GROUND:
			return ground_layer_mask
		BSEnums.SnapBehaviour.WALL:
			return wall_layer_mask
		BSEnums.SnapBehaviour.FREE:
			return free_layer_mask
		_:
			return ground_layer_mask

func toggle_pause_game():
	_main_menu.visible = not _main_menu.visible
	#get_tree().paused = not get_tree().paused

func _on_new_game_event():
	reset()
	_main_menu.visible = not _main_menu.visible
	
func on_exit_game_event():
	get_tree().quit()

func on_object_menu_interact(index, _button):
	if _is_demolish_mode_active:
		set_demolition_mode(false)
	_selected_object = buildable_object_library.buildable_objects[index]
	clear_mouse_object()
	_mouse_object.update_visual(_selected_object)

# Continuation of GDScript conversion for BuildingSystem

func _save(overwrite: bool):
	_save_system.save(overwrite, _free_objects_list, _grids)

func _load(filename: String):
	reset()
	_save_system.load(filename, buildable_object_library, _free_objects_list, _free_objects_container, free_layer_mask, _grids)

func reset():
	for free_object in _free_objects_list:
		free_object.clear_object()
	_free_objects_list.clear()
	for grid in _grids:
		grid.reset_grid()

func clear_mouse_object():
	_current_rotation = 0
	_mouse_object.clear_mouse_object()

# Additional utility methods that may be needed
func update_mouse_object_visual(delta):
	if _is_build_mode_active and _mouse_object.has_mouse_object():
		if _selected_object.snap_behaviour != BSEnums.SnapBehaviour.FREE:
			# Snap to grid
			_last_snapped_position = _active_grid.get_mouse_snapped_position(_current_mouse_position, _mouse_object)
			_mouse_object.global_position = _mouse_object.global_position.lerp(_last_snapped_position, delta * 15)
		else:
			# Free placement
			_mouse_object.global_position = Vector3(_current_mouse_position.x, _active_grid.global_position.y, _current_mouse_position.z)

		if ground_mouse_visible:
			_ground_mouse_node.global_position = Vector3(_current_mouse_position.x, _active_grid.global_position.y, _current_mouse_position.z)

func complete_delayed_drag():
	# Logic for completing a delayed drag operation, like placing a large object after moving the mouse
	print("Delayed drag completed")

func update_drag_rectangle():
	if not _drag_rectangle_mesh:
		_drag_rectangle_mesh = MeshInstance3D.new()
		add_child(_drag_rectangle_mesh)

	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2((_mouse_end_position.x - _mouse_start_position.x), (_mouse_end_position.z - _mouse_start_position.z))
	plane_mesh.center_offset = Vector3((_mouse_end_position.x + _mouse_start_position.x) / 2, _mouse_start_position.y + drag_visual_ground_offset, (_mouse_end_position.z + _mouse_start_position.z) / 2)
	_drag_rectangle_mesh.mesh = plane_mesh

func on_drag_delayed():
	# Additional logic to handle while dragging an object
	update_drag_rectangle()
	
func set_build_mode(active: bool):
	_is_build_mode_active = active
	_object_menu.visible = _is_build_mode_active
	if not _is_build_mode_active:
		clear_mouse_object()
	BSEventBus.build_mode_changed.emit(_is_build_mode_active)

func set_demolition_mode(active: bool):
	_is_demolish_mode_active = active
	if _is_demolish_mode_active:
		_active_layer_mask = _demolish_layer_mask
	else:
		_active_layer_mask = ground_layer_mask
		if is_instance_valid(_demolish_collider):
			_demolish_collider.get_parent().set_demolition_view(false)
		_demolish_collider = null
	BSEventBus.emit_signal("DemolitionModeChanged", _is_demolish_mode_active)
