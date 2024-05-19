# Utility class for animation-related functions.
class_name AnimationUtils
	# Animates the placement of a Node3D by scaling it down and then back to its original scale.
static func animate_placement(node: Node3D) -> void:
	var original_scale = node.scale
	node.scale *= 0.8  # Scale down to 80% of original size
	var tween = node.create_tween()
	tween.tween_property(node, "scale",original_scale, 0.1).set_trans(Tween.TRANS_BOUNCE)

