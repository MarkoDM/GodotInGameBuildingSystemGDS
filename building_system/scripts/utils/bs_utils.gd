# Utility class containing various helper methods for the building system.
class_name BSUtils

# Gets position of the mouse cursor in the 3D world.
static func get_raycast_point(mouse_position, world, camera, layer_mask):
	var space_state = world.direct_space_state
	var origin = camera.project_ray_origin(mouse_position)
	var end = origin + camera.project_ray_normal(mouse_position) * 999
	var result = space_state.intersect_ray(origin, end, [], layer_mask)

	#if result.size() > 0:
		#return result.position
	
	if "position" in result:
		return result["position"]

	return Vector3.ZERO

# Finds the first MeshInstance3D child node of the specified parent node.
static func find_mesh_instance(parent: Node3D) -> MeshInstance3D:
	for child in parent.get_children():
		if child is MeshInstance3D:
			return child
	return null

 # Registers input actions for the grid building system.
static func register_input_actions():
	var input_actions: Dictionary = {
		"rotate_object": KEY_R,
		"build_mode": KEY_B,
		"grid_level_up": KEY_PAGEUP,
		"grid_level_down": KEY_PAGEDOWN,
		"demolish": KEY_DELETE,
		"toggle_menu": KEY_ESCAPE,
		"quick_save": KEY_F5,
		"quick_load": KEY_F9,
		"move_forward": KEY_W,
		"move_backward": KEY_S,
		"move_left": KEY_A,
		"move_right": KEY_D,
		"rotate_left": KEY_Q,
		"rotate_right": KEY_E,
	}
	
	for action_name in input_actions.keys():
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)
			var input_event = InputEventKey.new()
			input_event.physical_keycode = input_actions[action_name]
			InputMap.action_add_event(action_name, input_event)
