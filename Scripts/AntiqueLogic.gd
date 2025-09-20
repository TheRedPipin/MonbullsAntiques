extends Node3D

@export var selected_index: int = -1
@export var sprites: Array[Texture]

func _ready() -> void:
	$Sprite3D.texture = sprites[selected_index]
