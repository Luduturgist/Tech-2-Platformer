extends Camera2D
class_name Game_Cam

@export var custom_offset: Vector2
@export var speed: float = 45


var director: Cam_Director
var follow: Node2D
var velocity: Vector2

func _camera_start(transfer: Vector2 = Vector2.INF):
	director = get_parent()
	
	if transfer != Vector2.INF:
		global_position = transfer
	elif follow:
		global_position = follow.global_position
	
	velocity = Vector2.ZERO
	make_current()

func velocity_follow(delta: float, target_pos: Vector2) -> Vector2:
	
	var diff = target_pos - global_position
	var dir = diff.normalized() * speed * delta * sqrt(diff.length())
	
	if diff.length() < dir.length():
		return target_pos
	
	velocity += dir
	velocity.x *= 0.5
	if velocity.y > 0:
		velocity.y *= 0.7
	else:
		velocity.y *= 0.5
	
	return global_position + velocity

func soft_follow(delta: float, target_pos: Vector2) -> Vector2:
	var diff = target_pos - global_position
	var dir = diff.normalized() * speed * delta * sqrt(diff.length())
	
	var calc_position: Vector2 = global_position
	
	if abs(diff.x) < abs(dir.x):
	#	global_position.x += dir.x
	#else:
		calc_position.x += diff.x
	
	if abs(diff.y) < abs(dir.y):
	#	global_position.y += dir.y
	#else:
		calc_position.y += diff.y
	
	if diff.y > 0:
		dir.y *= dir.y / 3
	else: 
		#dir.y /= 8 / -dir.y
		pass
	
	if diff.length() >= dir.length():
		calc_position += dir
	else:
		calc_position += diff
	
	return calc_position
	#30 in full 1920x1080, 50 in 640x360 or lower
	
	
	
	#if not follow: return
	#var diff = follow.global_position - global_position
	#var dir = Vector2(sign(diff.x), sign(diff.y)) * speed * delta * sqrt(diff.length())
