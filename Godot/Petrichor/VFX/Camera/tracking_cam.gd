extends Game_Cam
class_name TrackingCam

@export var speed: float = 45

func _ready() -> void:
	if follow: global_position = follow.global_position

func _physics_process(delta: float) -> void:
	if not follow: return
	var diff = follow.global_position - global_position
	var dir = diff.normalized() * speed * delta * sqrt(diff.length())
	
	if abs(diff.x) < abs(dir.x):
	#	global_position.x += dir.x
	#else:
		global_position.x += diff.x
		diff = follow.global_position - global_position
		dir = diff.normalized() * speed * delta * sqrt(diff.length())
	
	if abs(diff.y) < abs(dir.y):
	#	global_position.y += dir.y
	#else:
		global_position.y += diff.y
		diff = follow.global_position - global_position
		dir = diff.normalized() * speed * delta * sqrt(diff.length())

	
	if diff.y > 0:
		dir.y *= dir.y / 3
	else: 
		#dir.y /= 8 / -dir.y
		pass
	
	if diff.length() >= dir.length():
		global_position += dir
	else:
		global_position += diff
	
	#30 in full 1920x1080, 50 in 640x360 or lower
	
	
	
	#if not follow: return
	#var diff = follow.global_position - global_position
	#var dir = Vector2(sign(diff.x), sign(diff.y)) * speed * delta * sqrt(diff.length())
	
