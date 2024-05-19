# Represents an instance of a buildable object in the grid building system.
extends Node3D
class_name BuildableInstance

var buildable_resource = null
var object_instance = null
var _body = null
var _collider = null
var _demolition_visual = null
var _cells = [GridCell]

func initialize(resource, layer_mask):
	object_instance = resource.object_3d_model.instantiate()
	add_child(object_instance)
	buildable_resource = resource
	_cells = []
	_create_collider(layer_mask)
	_create_demolish_visual()

# Adds a grid cell to the buildable instance.
func add_cell(cell):
	_cells.append(cell)

# Clears the buildable instance and removes it from the grid cells.
func clear_object():
	for cell in _cells:
		if cell:
			if buildable_resource.snap_behaviour == BSEnums.SnapBehaviour.GROUND:
				cell.clear_ground_object()
			else:
				cell.clear_wall_object_by_instance(self)
	_cells = []
	object_instance.queue_free()
	queue_free()

# Sets the demolition view of the buildable instance.
func set_demolition_view(enabled):
	_demolition_visual.visible = enabled
	object_instance.visible = not enabled

func _create_collider(layer_mask):
	var shape = BoxShape3D.new()
	shape.size = _get_size()
	_collider = CollisionShape3D.new()
	_collider.shape = shape
	_body = StaticBody3D.new()
	_body.collision_layer = layer_mask
	_body.add_child(_collider)
	add_child(_body)
	# Optionally set floor collider offset based on the thickness of the floor
	var offset = buildable_resource.snap_behaviour == BSEnums.SnapBehaviour.WALL if Vector3(0, buildable_resource.size.y / 2, 0) else Vector3.ZERO
	_collider.position = offset

func _create_demolish_visual():
	var cube_mesh = BoxMesh.new()
	cube_mesh.size = _get_size()
	var material = StandardMaterial3D.new()
	material.albedo_color = Color.DARK_RED
	material.albedo_color.a = 0.8
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_demolition_visual = MeshInstance3D.new()
	_demolition_visual.mesh = cube_mesh
	_demolition_visual.material_override = material
	add_child(_demolition_visual)
	_demolition_visual.visible = false
	# Same as collider
	var offset = buildable_resource.snap_behaviour == BSEnums.SnapBehaviour.WALL if Vector3(0, buildable_resource.size.y / 2, 0) else Vector3.ZERO
	_demolition_visual.position = offset

func _get_size():
	var size = Vector3(1, 1, 1)
	match buildable_resource.snap_behaviour:
		BSEnums.SnapBehaviour.GROUND:
			size = Vector3(buildable_resource.size.x, 0.2, buildable_resource.size.z)
		BSEnums.SnapBehaviour.WALL:
			size = Vector3(buildable_resource.size.x, buildable_resource.size.y, 0.2)
		BSEnums.SnapBehaviour.FREE:
			var mesh_instance = BSUtils.find_mesh_instance(object_instance)
			if mesh_instance:
				var aabb = mesh_instance.mesh.get_aabb()
				var free_size = aabb.size
				size = free_size
	return size
