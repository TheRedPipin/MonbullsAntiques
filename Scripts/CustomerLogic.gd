extends Node3D

# ---------- Movement / Customer ----------
@export var customer_scene: PackedScene
@export var spawn_point: Node3D
@export var end_point : Node3D 
@export var speed: float = 3.0
@export var rotate_with_path: bool = true

var curve: Curve3D
var length: float = 0.0
var customer: Node3D = null
var customers_num: int = 0
var moving: bool = false
var announced: bool = false
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

# ---------- Shop / Antiques ----------
@export var antique_scene: PackedScene
@export var spawn_markers: Array[Node3D] = []

@export var color_amount: int = 6
@export var type_amount: int = 3
var shop_colors: Array[int] = []
var shop_types: Array[int] = []

func _ready() -> void:
	_spawn_and_start()
	generate_shop(spawn_markers.size())

func _spawn_and_start() -> void:
	customer = customer_scene.instantiate()
	customer.position = spawn_point.position
	add_child(customer)
	var tw = await customer.move_to_endpoint(end_point, 3.0)
	await tw.finished
	customer.type_text("May I please have a [font=res://Fonts/Eater-Regular.ttf]Jargack[/font] in [font=res://Fonts/Eater-Regular.ttf]Drosk[/font]")

func generate_shop(request_count: int) -> void:
	var count: int = min(request_count, spawn_markers.size())
	for i in range(count):
		var marker: Node3D = spawn_markers[i]
		if marker == null:
			continue
		var t_idx: int = rng.randi_range(0, type_amount - 1)
		var c_idx: int = rng.randi_range(0, color_amount - 1)
		var inst: Node3D = antique_scene.instantiate() as Node3D
		inst.set("selected_index", t_idx)
		inst.set("color_index", c_idx)
		add_child(inst)
		inst.global_transform = marker.global_transform
