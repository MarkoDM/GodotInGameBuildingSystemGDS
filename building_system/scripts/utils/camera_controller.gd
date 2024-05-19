# Controls the movement and rotation of the camera in a 3D space.
# Attach this script to a Node3D that is a parent of a Camera3D to enable camera movement and rotation.
extends Node3D
class_name CameraController
# Exported variables for easy adjustment in the Godot editor.
@export var movement_speed: float = 10.0
@export var rotation_speed: float = 2.0

# The _physics_process function handles the physics-related updates.
func _physics_process(delta):
	var velocity = Vector3.ZERO

	# Handle forward and backward movements
	if Input.is_action_pressed("move_forward"):
		velocity -= transform.basis.z
	if Input.is_action_pressed("move_backward"):
		velocity += transform.basis.z

	# Handle strafe movements (left and right)
	if Input.is_action_pressed("move_left"):
		velocity -= transform.basis.x
	if Input.is_action_pressed("move_right"):
		velocity += transform.basis.x

	# Normalize and scale velocity
	if velocity.length() > 0:
		velocity = velocity.normalized() * movement_speed * delta
		global_transform = Transform3D(global_transform.basis, global_transform.origin + velocity)

	# Handle rotations (Q for left, E for right)
	if Input.is_action_pressed("rotate_left"):
		rotate_y(rotation_speed * delta)
	if Input.is_action_pressed("rotate_right"):
		rotate_y(-rotation_speed * delta)
