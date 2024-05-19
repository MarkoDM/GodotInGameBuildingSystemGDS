# Represents a cell in a grid-based building system.
class_name GridCell

var ground_object: BuildableInstance = null
var wall_objects = []

func _init():
	wall_objects.resize(2)  # Assuming there are 2 sides as per the original C#, adjust if needed.

# Sets the ground object on this grid cell.
func set_ground_object(buildable_instance):
	if buildable_instance.buildable_resource.snap_behaviour == BSEnums.SnapBehaviour.GROUND:
		ground_object = buildable_instance

# Clears the ground object from this grid cell.
func clear_ground_object():
	ground_object = null

# Sets the wall object on this grid cell.
func set_wall_object(buildable_instance, side):
	if buildable_instance.buildable_resource.snap_behaviour == BSEnums.SnapBehaviour.WALL:
		wall_objects[int(side)] = buildable_instance

# Clears the specified wall object from this grid cell.
func clear_wall_object_by_instance(wall):
	for i in range(wall_objects.size()):
		if wall_objects[i] == wall:
			wall_objects[i] = null

# Clears the wall object from the specified side of this grid cell.
func clear_wall_object_by_side(side):
	wall_objects[int(side)] = null

# Determines whether this grid cell has a ground object.
func has_ground_object():
	return ground_object != null

# Determines whether this grid cell has a wall object on the specified side.
func has_wall_object(side):
	return wall_objects[int(side)] != null

# Gets the wall object placed on the specified side of this grid cell.
func get_wall_object(side):
	return wall_objects[int(side)]
