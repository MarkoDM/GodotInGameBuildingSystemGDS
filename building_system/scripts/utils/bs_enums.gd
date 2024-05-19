# This script contains enums that are accessible globally in the project.
class_name BSEnums

# Represents the snap behavior of an object in the building system.
enum SnapBehaviour {
	GROUND,  # Represents the ground object.
	WALL,    # Represents the wall object.
	FREE     # Represents the free object.
}

# Represents the drag behavior of an object.
enum DragBehavior {
	NONE,              # No drag behavior.
	INSTANT_PLACEMENT, # Instantly places the object as the mouse is dragged.
	DELAYED_PLACEMENT  # This will draw an area and place object after dragging is done.
}

# Represents the sides of a 2D grid.
enum Side {
	MINUS_Z, # Represents the negative Z side of a 2D grid.
	MINUS_X, # Represents the negative X side of a 2D grid.
	Z,       # Represents the positive Z side of a 2D grid.
	X        # Represents the positive X side of a 2D grid.
}
