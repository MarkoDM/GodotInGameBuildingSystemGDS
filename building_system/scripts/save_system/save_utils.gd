extends Node

# Represents a save system for the grid building system

class_name SaveUtils

# Converts a GridPosition to a Vector3 with the specified Y coordinate
static func to_vector3_grid(position, y: float) -> Vector3:
	return Vector3(position.x, y, position.z)

# Converts a Vector3 to a GridPosition
static func to_grid_position(position: Vector3) -> Dictionary:
	return {
		"x": position.x,
		"z": position.z
	}

# Converts a FreePosition to a Vector3
static func to_vector3_free(position) -> Vector3:
	return Vector3(position.x, position.y, position.z)

# Converts a Vector3 to a FreePosition
static func to_free_position(position: Vector3) -> Dictionary:
	return {
		"x": position.x,
		"y": position.y,
		"z": position.z
	}

# Converts a BuildableInstance to a SaveGridObject
static func to_save_grid_object(buildable_object) -> Dictionary:
	return {
		"name": buildable_object.buildable_resource.name,
		"resource_path": buildable_object.buildable_resource.resource_path,
		"position": SaveUtils.to_grid_position(buildable_object.global_position),
		"y_rotation_radiants": buildable_object.rotation_degrees.y
	}

# Converts a BuildableInstance to a SaveFreeObject
static func to_save_free_object(buildable_object) -> Dictionary:
	return {
		"name": buildable_object.buildable_resource.name,
		"resource_path": buildable_object.buildable_resource.resource_path,
		"position": SaveUtils.to_free_position(buildable_object.position),
		"y_rotation_radiants": buildable_object.rotation.y
	}

# Converts a BuildingSystemGrid to a SaveGrid
static func to_save_grid(grid) -> Dictionary:
	var save_objects = []
	for grid_cell in grid.grid_cells:
		if grid_cell.ground_object != null:
			save_objects.append(SaveUtils.to_save_grid_object(grid_cell.ground_object))
		for wall in grid_cell.wall_objects:
			if wall != null:
				save_objects.append(SaveUtils.to_save_grid_object(wall))
	return {
		"objects": save_objects
	}
