extends Node

class_name BSSaveSystem

var _current_save_file: String = ""

# Initialize a new instance of the BSSaveSystem class.
func _init():
	pass

# Save the current state of the grid building system.
# @param overwrite: Whether to overwrite the existing save file.
# @param free_object_list: The list of free objects to save.
# @param grids: The list of grids to save.
func save(overwrite: bool, free_object_list: Array, grids: Array):
	var save_grids = []
	var free_objects = []

	for free_object in free_object_list:
		free_objects.append(SaveUtils.to_save_free_object(free_object))

	for i in range(grids.size()):
		var grid = SaveUtils.to_save_grid(grids[i])
		if grid.objects.size() > 0:
			grid.index = i
			save_grids.append(grid)

	var save_file = {
		"grids": save_grids,
		"free_objects": free_objects
	}

	if overwrite:
		_current_save_file = SaveSystem.save_data(save_file, _current_save_file)
	else:
		_current_save_file = SaveSystem.save_data(save_file)

# Load a saved state of the grid building system.
# @param filename: The name of the save file to load.
# @param buildable_object_library: The buildable object library.
# @param free_object_list: The list of free objects to load.
# @param free_object_container: The container node for free objects.
# @param free_layer_mask: The layer mask for free objects.
# @param grids: The list of grids to load.
func load(filename: String, buildable_object_library, free_object_list: Array, free_object_container: Node, free_layer_mask: int, grids: Array):
	_current_save_file = filename
	var save_file = SaveSystem.load_data(filename)

	if save_file:
		for i in range(save_file["grids"].size()):
			if save_file["grids"][i]["index"] == i:
				for grid_object in save_file["grids"][i]["objects"]:
					var buildable_object = buildable_object_library.get_by_name(grid_object["name"])
					grids[i].try_to_place_object(buildable_object, grid_object["y_rotation_radiants"], SaveUtils.to_vector3_grid(grid_object["position"], grids[i].global_position.y))

		for free_save_object in save_file["free_objects"]:
			var buildable_object = buildable_object_library.get_by_name(free_save_object["name"])
			var buildable_instance = BuildableInstance.new()
			free_object_container.add_child(buildable_instance)
			buildable_instance.initialize(buildable_object, free_layer_mask)
			buildable_instance.global_position = _to_vector3(free_save_object["position"])
			buildable_instance.rotate_y(free_save_object["y_rotation_radiants"])

			free_object_list.append(buildable_instance)

# Utility function to convert dictionary to Vector3
func _to_vector3(dict):
	return Vector3(dict["x"], dict["y"], dict["z"])
