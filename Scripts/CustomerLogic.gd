extends Node3D

# ---------- Movement / Customer ----------
@export var customer_scene: PackedScene
@export var spawn_point: Node3D
@export var end_point: Node3D
@export var cam: Camera3D
@export var speed: float = 3.0
@export var rotate_with_path: bool = true
@export var antique_scene: PackedScene
@export var spawn_markers: Array[Node3D] = []
@export var color_amount: int = 5
@export var type_amount: int = 3
var shop_colors: Array[int] = []
var shop_types: Array[int] = []
var attempts = 3
var customerNum = 0
var moneyAmounts = [50,75,100]
var customer: Node3D
var rng := RandomNumberGenerator.new()
var want_idx : int
func _ready() -> void:
	rng.randomize()
	cam.customer_targeted.connect(try_to_sell)
	generate_shop(spawn_markers.size())

func _spawn_and_start() -> void:
	customerNum += 1
	if customerNum == 5:
		Global.landlord = true
		customer = customer_scene.instantiate()
		add_child(customer)
		customer.global_position = spawn_point.global_position
		var tw = await customer.move_to_endpoint(end_point, 3.0)
		await tw.finished
		var msg := "I am landlord give money pls"
		await customer.type_text(msg)
		return
	elif customerNum == 6:
		customerNum = 0
		generate_shop(spawn_markers.size())
		return
	attempts = 3
	customer = customer_scene.instantiate()
	want_idx = rng.randi_range(0, shop_types.size() - 1)
	Global.noun_key = shop_types[want_idx]
	Global.adj_key = shop_colors[want_idx]
	add_child(customer)
	customer.global_position = spawn_point.global_position
	rng.randomize()
	var generic = rng.randf()
	if generic > 0.5:
		generic = false
	else:
		generic = true
	var tw = await customer.move_to_endpoint(end_point, 3.0)
	await tw.finished
	var msg : String
	var NPC_num = -1
	if generic:
		msg = Global.dialog["NPCG"][rng.randi_range(0, Global.dialog["NPCG"].size()-1)]
	else:
		for i in range(Global.NPC_Visits.size()):
			if Global.NPC_Visits[i] == false:
				NPC_num = i
				Global.NPC_Visits[i] = true
				msg = Global.dialog[str(NPC_num)][0]
		if NPC_num == -1:
			msg = Global.dialog["NPCG"][rng.randi_range(0, Global.dialog["NPCG"].size()-1)]
			generic = true
	if !msg.contains("NOUN"):
		Global.noun_key = -1
	else:
		msg = msg.replace("NOUN", Global.nouns[Global.noun_key])
	if !msg.contains("ADJ"):
		Global.adj_key = -1
	else:
		msg = msg.replace("ADJ", Global.adjectives[Global.adj_key])
	await customer.type_text(msg)

func generate_shop(request_count: int) -> void:
	for i in get_tree().get_nodes_in_group("Antique"):
		i.queue_free()
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
	_spawn_and_start()

func try_to_sell(customer: CharacterBody3D) -> void:
	if Global.landlord == true:
		if Global.money >= Global.landlordRequirement:
			Global.money -= Global.landlordRequirement
			customer.queue_free()
			Global.landlord = false
			_spawn_and_start()
	if (Global.noun_key == Global.onTable[0] or Global.noun_key == -1) and (Global.adj_key == Global.onTable[1] or Global.adj_key == -1):
		var findIndex = 0
		for i in get_tree().get_nodes_in_group("Antique"):
			if i.get_meta("on_desk") == true:
				i.queue_free()
				break
			findIndex += 1
		Global.money += moneyAmounts[attempts-1]
		shop_types.pop_at(findIndex)
		shop_colors.pop_at(findIndex)
		Global.onTable = [-1,-1]
		customer.queue_free()
		_spawn_and_start()
	else:
		attempts -= 1
		if attempts == 0:
			var msg := "This place sucks!"
			customer.remove_from_group("Customer")
			await customer.type_text(msg)
			customer.queue_free()
			_spawn_and_start()
		var msg := "twin sybau ♥🥀"
		await customer.type_text(msg)

func _physics_process(delta: float) -> void:
	$SubViewport/Control/Panel/Label.text = "You Have\n$%s" % [Global.money]
