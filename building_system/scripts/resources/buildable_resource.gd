# Represents a buildable resource in the grid building system.
# Every object that can be built in the grid building system needs to be a buildable resource.
# Creating a buildable resource allows you to define the visual representation of the object, its size, snap behavior, and other properties.
class_name BuildableResource extends Resource

# Properties exported to the Godot editor with appropriate hints.
@export var name: String
@export var description: String
@export var texture_atlas: AtlasTexture
@export var texture_image: Texture
@export var object_3d_model: PackedScene
@export var snap_behaviour: BSEnums.SnapBehaviour
@export var size: Vector3i  # Note: Adjust the type if needed to match specific requirements

func _init():
	name = ""
	description = ""
	texture_atlas = null
	texture_image = null
	object_3d_model = null
	snap_behaviour = BSEnums.SnapBehaviour.GROUND  # Default snap behaviour, adjust according to your requirements
	size = Vector3.ZERO  # Default size as zero, can be adjusted

func set_description(new_description: String):
	description = new_description

