# Represents a tile that is part of mouse object visual.
extends Node3D

var _collide_count: int = 0
var _override_material: StandardMaterial3D

@onready var _mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var _area: Area3D = $Area3D
@onready var _collision_shape_3D: CollisionShape3D = $Area3D/CollisionShape3D

func _ready():
	_area.body_entered.connect(_on_area_body_entered)
	_area.body_exited.connect(_on_area_body_exited)
	
	# Create a basic material to override the tile color when colliding
	_override_material = StandardMaterial3D.new()
	_override_material.albedo_color = Color.DARK_RED
	_override_material.albedo_color.a = 0.8
	_override_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_override_material.render_priority = 2

# Sets the collision layer mask for the tile.
func set_tile_layer_mask(layer_mask: int):
	_area.collision_mask = layer_mask

# Sets the size of the tile.
func set_size(size: int):
	var plane_mesh = _mesh_instance.mesh as PlaneMesh
	plane_mesh.size = Vector2(size, size)
	var shape = _collision_shape_3D.shape as BoxShape3D
	shape.size = Vector3(size * 0.8, 0.3, size * 0.8)

# Sets the visibility of the tile.
func set_visibility(is_tile_visible: bool):
	_mesh_instance.visible = is_tile_visible

# Checks if the tile is currently colliding with any other bodies.
func is_colliding() -> bool:
	return _collide_count != 0

func _on_area_body_entered(_body: Node3D):
	_collide_count += 1
	_mesh_instance.material_override = _override_material if _mesh_instance.material_override == null else _mesh_instance.material_override
	BSEventBus.mouse_tile_body_entered.emit()

func _on_area_body_exited(_body: Node3D):
	_collide_count -= 1
	if _collide_count == 0:
		_mesh_instance.material_override = null
		BSEventBus.mouse_tile_body_exited.emit()
