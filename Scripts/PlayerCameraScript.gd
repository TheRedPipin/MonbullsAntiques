extends Camera3D

@export var ray_length: float = 5.0
@export var desk_anchor: Node3D
@export var desk_offset: Vector3 = Vector3(0, 0.1, 0)
@export var outline_material: ShaderMaterial
@export var outline_width_local: float = 0.04

var _space_state: PhysicsDirectSpaceState3D
var _current_antique: Node3D = null
var _current_meshes: Array[MeshInstance3D] = []
var _desk_item: Node3D = null

func _ready() -> void:
	_space_state = get_world_3d().direct_space_state

func _process(_delta: float) -> void:
	_update_highlight()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and _current_antique != null:
		_toggle_antique(_current_antique)
		_clear_outline()
		_apply_outline(_current_antique)

# ---------------- Highlight ----------------
func _update_highlight() -> void:
	var hit: Dictionary = _raycast()
	var next_antique: Node3D = null
	if not hit.is_empty():
		var col: Node = hit["collider"] as Node
		next_antique = _get_antique_root(col)
	if next_antique != _current_antique:
		_clear_outline()
		_current_antique = next_antique
		if _current_antique != null:
			_apply_outline(_current_antique)

func _apply_outline(antique: Node3D) -> void:
	_current_meshes = _collect_meshes(antique)
	var mat: ShaderMaterial = outline_material.duplicate() as ShaderMaterial
	mat.set_shader_parameter("width_local", outline_width_local)
	for m in _current_meshes:
		m.material_overlay = mat

func _clear_outline() -> void:
	for m in _current_meshes:
		m.material_overlay = null
	_current_meshes.clear()

func _collect_meshes(root: Node) -> Array[MeshInstance3D]:
	var arr: Array[MeshInstance3D] = []
	var stack: Array[Node] = [root]
	while stack.size() > 0:
		var n: Node = stack.pop_back()
		var children: Array[Node] = n.get_children()
		for j in range(children.size()):
			stack.append(children[j])
		if n is MeshInstance3D:
			arr.append(n as MeshInstance3D)
	return arr

# ---------------- Pick / Place ----------------
func _toggle_antique(antique: Node3D) -> void:
	var on_desk: bool = false
	if antique.has_meta("on_desk"):
		on_desk = antique.get_meta("on_desk") as bool

	if on_desk:
		_return_to_original(antique)
		if _desk_item == antique:
			_desk_item = null
	else:
		if _desk_item != null:
			_return_to_original(_desk_item)
			_desk_item = null
		_place_on_desk(antique)
		_desk_item = antique

func _place_on_desk(antique: Node3D) -> void:
	if not antique.has_meta("orig_parent_path"):
		antique.set_meta("orig_parent_path", antique.get_parent().get_path())
	if not antique.has_meta("orig_global_xform"):
		antique.set_meta("orig_global_xform", antique.global_transform)
	var parent_now: Node = antique.get_parent()
	parent_now.remove_child(antique)
	desk_anchor.add_child(antique)
	var new_xform: Transform3D = Transform3D(
		desk_anchor.global_transform.basis,
		desk_anchor.global_transform.origin + desk_offset
	)
	antique.global_transform = new_xform
	antique.set_meta("on_desk", true)

func _return_to_original(antique: Node3D) -> void:
	var parent_path: NodePath = antique.get_meta("orig_parent_path") as NodePath
	var orig_xform: Transform3D = antique.get_meta("orig_global_xform") as Transform3D
	var orig_parent: Node = get_node(parent_path)
	var cur_parent: Node = antique.get_parent()
	cur_parent.remove_child(antique)
	orig_parent.add_child(antique)
	antique.global_transform = orig_xform
	antique.set_meta("on_desk", false)

# ---------------- Helpers ----------------
func _raycast() -> Dictionary:
	var from: Vector3 = global_transform.origin
	var to: Vector3 = from + -global_transform.basis.z * ray_length
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_bodies = true
	query.collide_with_areas = true
	return _space_state.intersect_ray(query)

func _get_antique_root(n: Node) -> Node3D:
	var p: Node = n
	while p != null:
		if p.is_in_group("Antique"):
			return p as Node3D
		p = p.get_parent()
	return null
