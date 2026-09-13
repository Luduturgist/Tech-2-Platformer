extends Area2D
class_name Area_Detector

var targets: Array[Node2D]
@export var target_script: Script = PlayerMovement
signal target_found
signal field_clear

func _ready():
	body_entered.connect(_try_find_target)
	body_exited.connect(_try_lose_target)

func _try_find_target(body: Node2D):
	if body.get_script() == target_script:
		targets.append(body)
		if targets.size() == 1:
			target_found.emit()
			#print("found")

func _try_lose_target(body: Node2D):
	if targets.find(body) < 0:
		return
	
	targets.remove_at(targets.find(body))
	if targets.size() == 0:
			#print("lost")
			field_clear.emit()

func _nearest_target(pos: Vector2 = Vector2.INF) -> Node2D:
	if targets.size() == 1:
		return targets[0]
	
	if pos == Vector2.INF:
		pos = global_position
	
	var dist: float = INF
	var target: Node2D = null
	for t in targets:
		var try_dist: float = (t.global_position - pos).length()
		if try_dist < dist:
			dist = try_dist
			target = t
	return target
