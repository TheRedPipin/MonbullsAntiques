extends Node3D

@export var customer_scene: PackedScene
@export var spawn_point: NodePath
@export var speed: float = 3.0
@export var look_ahead: float = 0.2

var customer: Node3D = null
@onready var path: Path3D = $"Path3D"
var curve: Curve3D
var distance: float = 0.0
var length: float = 0.0
var moving: bool = false
var announced: bool = false

func _ready() -> void:
	curve = path.curve
	length = curve.get_baked_length()
	_spawn_and_start()

func _spawn_and_start() -> void:
	if customer_scene == null:
		return
	var sp: Node3D = get_node(spawn_point) as Node3D
	customer = customer_scene.instantiate() as Node3D
	get_tree().current_scene.add_child(customer)
	customer.global_transform = sp.global_transform
	distance = 0.0
	moving = true
	announced = false
	set_physics_process(true)

func _physics_process(delta: float) -> void:
	if not moving or customer == null:
		return

	if distance >= length:
		customer.global_position = curve.sample_baked(length)
		moving = false
		set_physics_process(false)

		if not announced and customer.has_method("type_text"):
			announced = true
			customer.type_text("Hello Person of the [font=res://Fonts/Eater-Regular.ttf]Jargack[/font]")
		return

	distance = min(distance + speed * delta, length)

	var pos: Vector3 = curve.sample_baked(distance)
	customer.global_position = pos

	var ahead_dist: float = min(distance + look_ahead, length)
	var ahead_pos: Vector3 = curve.sample_baked(ahead_dist)
	var dir: Vector3 = ahead_pos - pos
	if dir.length_squared() > 0.0:
		customer.look_at(pos + dir.normalized(), Vector3.UP)
