extends Node3D

@export var variants: Array[MeshInstance3D] = []
@export var selected_index: int = -1

func _ready() -> void:
	for i in range(variants.size()):
		var m: MeshInstance3D = variants[i]
		if m != null:
			m.visible = false
	if selected_index >= 0 and selected_index < variants.size():
		_show_variant(selected_index)

func _show_variant(idx: int) -> void:
	for i in range(variants.size()):
		var m: MeshInstance3D = variants[i]
		if m != null:
			m.visible = (i == idx)
	selected_index = idx

func set_variant_by_index(idx: int) -> void:
	if idx >= 0 and idx < variants.size():
		_show_variant(idx)
