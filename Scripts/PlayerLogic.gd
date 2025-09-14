extends CharacterBody3D

@export var mouse_sensitivity: float = 0.05
@export var min_pitch: float = -60.0
@export var max_pitch: float = 60.0
@export var min_yaw: float = -90.0
@export var max_yaw: float = 90.0


var base_yaw: float = 0.0
var base_pitch: float = 0.0
var yaw: float = 0.0
var pitch: float = 0.0

@onready var cam: Camera3D = $Camera3D

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	base_yaw = rotation.y
	base_pitch = cam.rotation.x
	yaw = base_yaw
	pitch = base_pitch

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		yaw -= event.relative.x * mouse_sensitivity
		pitch -= event.relative.y * mouse_sensitivity
		yaw = clamp(yaw, base_yaw + deg_to_rad(min_yaw), base_yaw + deg_to_rad(max_yaw))
		pitch = clamp(pitch, base_pitch + deg_to_rad(min_pitch), base_pitch + deg_to_rad(max_pitch))
		rotation.y = yaw
		cam.rotation.x = pitch
