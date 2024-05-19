# Represents a library of BuildableResource
# This class is used to store an array of buildable objects that can be built in the grid building system.
# It provides an easy way of creating and managing buildable objects using multiple libraries (for testing or menus etc.).
class_name BuildableResourceLibrary extends Resource

# Property to store an array of BuildableResource
@export var buildable_objects: Array[BuildableResource]

func _init():
	self.buildable_objects = []

# Method to get the buildable resource by name.
# Returns the buildable resource with the specified name, or null if not found.
func get_by_name(name: String) -> BuildableResource:
	for obj in buildable_objects:
		if obj and obj.name == name:
			return obj
	return null
