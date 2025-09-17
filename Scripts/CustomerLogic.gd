extends Node3D

@export var customer_scene: PackedScene
@export var spawn_point: Node3D
@export var speed: float = 3.0
@export var rotate_with_path: bool = true
@export var color_amount: int = 6
@export var type_amount: int = 2
@onready var path: Path3D = $Path3D
@onready var follower: PathFollow3D = $Path3D/Follower
var curve: Curve3D
var length: float = 0.0
var customer: Node3D = null
var customersNum: int = 0
var moving: bool = false
var announced: bool = false
var shop_colors: Array = []
var shop_types: Array = []


func _ready() -> void:
	curve = path.curve
	length = curve.get_baked_length()
	_spawn_and_start()

func _spawn_and_start() -> void:
	if customer_scene == null or spawn_point == null:
		return
	customer = customer_scene.instantiate() as Node3D
	follower.progress = 0.0
	follower.loop = false
	follower.add_child(customer)
	customer.global_transform = spawn_point.global_transform
	moving = true
	announced = false
	set_physics_process(true)

func _physics_process(delta: float) -> void:
	if moving:
		follower.progress = min(follower.progress + speed * delta, length)
		if follower.progress >= length:
			moving = false
			set_physics_process(false)
			if not announced and customer.has_method("type_text"):
				announced = true
				customer.type_text("May I please have a [font=res://Fonts/Eater-Regular.ttf]Jargack[/font] in [font=res://Fonts/Eater-Regular.ttf]Drosk[/font]")
				customersNum += 1

func generateShop():
	randomize()
	shop_colors = []
	shop_types = []
	for i in range(8):
		shop_colors.append(randi_range(0,color_amount-1))
		shop_types.append(randi_range(0,type_amount-1))
	
