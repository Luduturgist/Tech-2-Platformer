extends Game_Cam
class_name TrackingCam

@export var speed: float = 45

var velocity: Vector2
var subpixel_position: Vector2

func _camera_start(transfer: Vector2 = Vector2.INF):
	super._camera_start()
	velocity = Vector2.ZERO
	if transfer != Vector2.INF:
		global_position = transfer
	subpixel_position = global_position

func _physics_process(delta: float) -> void:
	if not director:
		return
	
	velocity_follow(delta)
	
	global_position = subpixel_position + director.director_offset

func velocity_follow(delta: float):
	if not follow or not is_current():
		return
	
	var diff = follow.global_position - subpixel_position
	var dir = diff.normalized() * speed * delta * sqrt(diff.length())
	
	if diff.length() < dir.length():
		return
	
	velocity += dir
	velocity.x *= 0.5
	if velocity.y > 0:
		velocity.y *= 0.7
	else:
		velocity.y *= 0.5
	
	
	subpixel_position += velocity

func soft_follow(delta: float):
	if not follow:
		return
	
	var diff = follow.global_position - subpixel_position
	var dir = diff.normalized() * speed * delta * sqrt(diff.length())
	
	if abs(diff.x) < abs(dir.x):
	#	global_position.x += dir.x
	#else:
		subpixel_position.x += diff.x
		diff = follow.global_position - subpixel_position
		dir = diff.normalized() * speed * delta * sqrt(diff.length())
	
	if abs(diff.y) < abs(dir.y):
	#	global_position.y += dir.y
	#else:
		subpixel_position.y += diff.y
		diff = follow.global_position - subpixel_position
		dir = diff.normalized() * speed * delta * sqrt(diff.length())

	
	if diff.y > 0:
		dir.y *= dir.y / 3
	else: 
		#dir.y /= 8 / -dir.y
		pass
	
	if diff.length() >= dir.length():
		subpixel_position += dir
	else:
		subpixel_position += diff
	
	
	#30 in full 1920x1080, 50 in 640x360 or lower
	
	
	
	#if not follow: return
	#var diff = follow.global_position - global_position
	#var dir = Vector2(sign(diff.x), sign(diff.y)) * speed * delta * sqrt(diff.length())
