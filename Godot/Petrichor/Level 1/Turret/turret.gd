@icon("res://Level 1/turret_head.png")
extends Area2D
class_name Turret

@export var head: Node2D
@export var muzzle: Node2D
@export var projectile: PackedScene
@export var target: Node2D
@export var filter: Script = PlayerMovement

var active: bool = true
var targets: Array[Node2D]

func _ready() -> void:
	body_entered.connect(track_target)
	area_entered.connect(track_target)
	body_exited.connect(untrack_target)
	area_exited.connect(untrack_target)

func track_target(body: Node2D):
	if body.get_script() == filter:
		print("hello")
		targets.append(body)
		if not target:
			target = body
			aim()

func untrack_target(body: Node2D):
	if body.get_script() == filter:
		print("are you still there?")
		targets.remove_at(targets.find(body))
		if target == body:
			target = null
			if targets.size():
				target = targets[0]

func _process(_delta: float) -> void:
	aim()
	queue_redraw()

func aim():
	if not target or not active: return
	
	var dist: float = abs((global_position - target.global_position).length())
	for t in targets:
		var d: float = abs((global_position - t.global_position).length())
		if dist > d:
			target = t
			dist = d
	
	var offset: Vector2 = target.global_position - (muzzle.position.rotated(head.rotation))
	head.look_at(offset)

func _set_turret(value: bool):
	active = value
	aim()

@rpc("authority", "reliable")
func change_target(new_target: PlayerMovement, rot: float):
	if new_target == null:
		target = null
		head.rotation = rot
		return
	if rot == INF:
		active = true
	elif rot == -INF:
		active = false

	target = new_target

func _draw():
	draw_line(muzzle.global_position - global_position, $"Head/Muzzle Debug".global_position - global_position, Color.RED)
	pass
