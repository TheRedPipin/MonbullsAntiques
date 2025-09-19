extends Node3D

# ---------- Movement / Customer ----------
@export var customer_scene: PackedScene
@export var spawn_point: Node3D
@export var speed: float = 3.0
@export var rotate_with_path: bool = true

@onready var path: Path3D = $Path3D
@onready var follower: PathFollow3D = $Path3D/Follower

var curve: Curve3D
var length: float = 0.0
var customer: Node3D = null
var customers_num: int = 0
var moving: bool = false
var announced: bool = false

# ---------- Shop / Antiques ----------
@export var antique_scene: PackedScene
@export var spawn_markers: Array[Node3D] = []         # assign Antique1..Antique5 here (optional)

@export var color_amount: int = 6
@export var type_amount: int = 2
var shop_colors: Array[int] = []
var shop_types: Array[int] = []

func _ready() -> void:
	curve = path.curve
	length = curve.get_baked_length()
	_spawn_and_start()
	generate_shop(spawn_markers.size())

func _spawn_and_start() -> void:
	if customer_scene == null or spawn_point == null:
		return
	customer = customer_scene.instantiate() as Node3D
	follower.progress = 0.0
	follower.loop = false
	follower.rotation_mode = PathFollow3D.ROTATION_ORIENTED if rotate_with_path else PathFollow3D.ROTATION_NONE
	follower.add_child(customer)
	customer.global_transform = spawn_point.global_transform
	moving = true
	announced = false
	set_physics_process(true)

func _physics_process(delta: float) -> void:
	if not moving:
		return
	follower.progress = min(follower.progress + speed * delta, length)
	if follower.progress >= length:
		moving = false
		set_physics_process(false)
		if not announced and customer != null and customer.has_method("type_text"):
			announced = true
			customer.type_text("May I please have a [font=res://Fonts/Eater-Regular.ttf]Jargack[/font] in [font=res://Fonts/Eater-Regular.ttf]Drosk[/font]")
			customers_num += 1

# ---------- Shop generation ----------
func generate_shop(request_count: int) -> void:
	shop_colors.clear()
	shop_types.clear()

	for i in range(request_count):
		var t_idx: int = i % (type_amount if type_amount > 0 else 1)
		var c_idx: int = i % (color_amount if color_amount > 0 else 1)
		shop_types.append(t_idx)
		shop_colors.append(c_idx)

	var count: int = min(request_count, spawn_markers.size())
	for i in range(count):
		var marker: Node3D = spawn_markers[i]
		if marker == null:
			continue
		var inst: Node3D = antique_scene.instantiate() as Node3D
		# Adjust property names if your Antique script differs:
		inst.set("selected_index", shop_types[i])   # which model/shape to show
		inst.set("color_index", shop_colors[i])     # optional color index
		self.add_child(inst)
		inst.global_transform = marker.global_transform
