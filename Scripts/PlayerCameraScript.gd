extends Camera3D

@export var ray_length: float = 100.0
@export var outline_material: ShaderMaterial = preload("res://shaders/outline.tres")

var current_target: MeshInstance3D

func _physics_process(_delta: float) -> void:
	var from = global_transform.origin
	var to = from + -global_transform.basis.z * ray_length

	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_bodies = true

	var result = get_world_3d().direct_space_state.intersect_ray(query)

	if result and result.collider and result.collider.is_in_group("Antique"):
		# Get the MeshInstance3D child of the hit Antique
		var mesh := result.collider.get_node("MeshInstance3D") as MeshInstance3D
		if mesh and mesh != current_target:
			_clear_outline()
			mesh.material_overlay = outline_material
			current_target = mesh
	else:
		_clear_outline()

func _clear_outline() -> void:
	if current_target:
		current_target.material_overlay = null
		current_target = null
