extends Node3D

@export var variants: Array[MeshInstance3D] = []
@export var selected_index: int = -1
@export var color_index: int = -1

@export var palette: Array[Color] = [
	Color(1, 1, 1),      # 0 white
	Color(1, 0, 0),      # 1 red
	Color(0, 0, 1),      # 2 blue
	Color(0, 1, 0),      # 3 green
	Color(1, 1, 0),      # 4 yellow
]

func _ready() -> void:
	for i in range(variants.size()):
		var m: MeshInstance3D = variants[i]
		if m != null:
			m.visible = false
	if selected_index >= 0 and selected_index < variants.size():
		_show_variant(selected_index)
	_apply_color_from_index()

func _show_variant(idx: int) -> void:
	for i in range(variants.size()):
		var m: MeshInstance3D = variants[i]
		if m != null:
			m.visible = (i == idx)
	selected_index = idx

func set_variant_by_index(idx: int) -> void:
	if idx >= 0 and idx < variants.size():
		_show_variant(idx)
		_apply_color_from_index()

func set_color_by_index(idx: int) -> void:
	color_index = idx
	_apply_color_from_index()

func _apply_color_from_index() -> void:
	if color_index < 0 or color_index >= palette.size():
		return
	var tint: Color = palette[color_index]
	for i in range(variants.size()):
		var mesh: MeshInstance3D = variants[i]
		var src_mat: Material = mesh.material_override
		var mat: Material = src_mat.duplicate(true)
		var std := mat as StandardMaterial3D
		std.albedo_color = tint
		mesh.material_override = mat
