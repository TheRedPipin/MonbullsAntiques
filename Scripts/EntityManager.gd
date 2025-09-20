extends CharacterBody3D

@export var label: RichTextLabel
@export var panel: Panel
@export var Grunt: AudioStreamPlayer3D
@export var cps: float = 20.0
@export var sprites: Array[Texture]

var _task_id: int = 0

func _ready() -> void:
	label.bbcode_enabled = true
	label.text = ""
	label.visible_characters = 0
	randomize()
	$Sprite3D.texture = sprites[randi_range(0,sprites.size()-1)]


func type_text(message: String) -> void:
	_task_id += 1
	var my_task := _task_id
	Grunt.play()
	if label == null:
		return
	panel.visible = true
	label.bbcode_enabled = true
	label.text = message
	label.visible_characters = 0

	if cps <= 0.0:
		label.visible_characters = -1
		return
	var delay := 1.0 / cps
	var total := label.get_total_character_count()

	for i in range(1, total + 1):
		if my_task != _task_id:
			return
		label.visible_characters = i
		await get_tree().create_timer(delay).timeout


func stop_typing() -> void:
	_task_id += 1
	if label:
		label.visible_characters = 0
		panel.visible = true

func move_to_endpoint(end_point: Node3D, duration: float = 2.0):
	var target_pos: Vector3 = end_point.global_position
	var tw := create_tween()
	tw.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tw.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(self, "global_position", target_pos, duration)
	return tw
