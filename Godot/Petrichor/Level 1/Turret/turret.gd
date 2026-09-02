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
		aim()

func untrack_target(body: Node2D):
	if body.get_script() == filter:
		print("are you still there?")
		targets.remove_at(targets.find(body))
		if target == body:
			target = null
			if targets.size():
				target = targets[0]

func _physics_process(_delta: float) -> void:
	aim()
	queue_redraw()

func aim():
	if not active or not targets.size(): return
	
	if not target or targets.size() > 1:
		target = nearest_target(true)
		if target == null: return
	
	var offset: Vector2
	if (muzzle.global_position - target.global_position).length() > (global_position - muzzle.global_position).length():
		offset = target.global_position - (muzzle.position.rotated(head.rotation))
	else:
		offset = target.global_position
	head.look_at(offset)

func nearest_target(_visible: bool = true) -> Node2D:
	var closest_target: Node2D = null
	if target: closest_target = target
	var dist: float = INF
	if target: dist = abs((global_position - target.global_position).length())
	for t in targets:
		var d: float = abs((global_position - t.global_position).length())
		if dist > d:
			closest_target = t
			dist = d
	return closest_target

func _set_turret(value: bool):
	active = value
	if value: aim()

func _draw():
	if target:
		draw_line(muzzle.global_position - global_position, $"Head/Muzzle Debug".global_position - global_position, Color.GREEN)
	#elif targets.size():
		#draw_line(muzzle.global_position - global_position, nearest_target(false).global_position - global_position, Color.YELLOW)
	else:
		draw_line(muzzle.global_position - global_position, $"Head/Muzzle Debug".global_position - global_position, Color.RED)
