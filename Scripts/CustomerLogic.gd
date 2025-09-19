extends Node3D

# ---------- Movement / Customer ----------
@export var customer_scene: PackedScene
@export var spawn_point: Node3D
@export var end_point: Node3D
@export var cam: Camera3D
@export var speed: float = 3.0
@export var rotate_with_path: bool = true

var customer: Node3D
var rng := RandomNumberGenerator.new()

@export var antique_scene: PackedScene
@export var spawn_markers: Array[Node3D] = []
@export var color_amount: int = 6
@export var type_amount: int = 3
var shop_colors: Array[int] = []
var shop_types: Array[int] = []
func _ready() -> void:
	rng.randomize()
	cam.customer_targeted.connect(try_to_sell)
	generate_shop(spawn_markers.size())
	await _spawn_and_start()

func _spawn_and_start() -> void:
	customer = customer_scene.instantiate()
	add_child(customer)
	customer.global_position = spawn_point.global_position
	var tw = await customer.move_to_endpoint(end_point, 3.0)
	await tw.finished
	var want_idx := rng.randi_range(0, shop_types.size() - 1)
	Global.noun_key = shop_types[want_idx]
	Global.adj_key = shop_colors[want_idx]
	var msg := "May I please have a [font=res://Fonts/Eater-Regular.ttf]%s[/font] in [font=res://Fonts/Eater-Regular.ttf]%s[/font]" % [Global.nouns[Global.noun_key], Global.adjectives[Global.adj_key]]
	await customer.type_text(msg)

func generate_shop(request_count: int) -> void:
	var count = min(request_count, spawn_markers.size())
	shop_colors.clear()
	shop_types.clear()
	for i in range(count):
		var t_idx := rng.randi_range(0, max(1, type_amount) - 1)
		var c_idx := rng.randi_range(0, max(1, color_amount) - 1)
		shop_types.append(t_idx)
		shop_colors.append(c_idx)
		var marker := spawn_markers[i]
		var inst := antique_scene.instantiate() as Node3D
		inst.set("selected_index", t_idx)
		inst.set("color_index", c_idx)
		add_child(inst)
		inst.global_transform = marker.global_transform


func try_to_sell(customer: CharacterBody3D) -> void:
	print(Global.noun_key, Global.adj_key, Global.onTable)
	if Global.noun_key == Global.onTable[0] and Global.adj_key == Global.onTable[1]:
		print("Correct")
