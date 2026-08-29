extends Camera2D
class_name TrackingCam

@export var follow: Node2D
var speed: float = 20

func _ready() -> void:
	if follow: global_position = follow.global_position

func _process(delta: float) -> void:
	if not follow: return
	var diff = follow.global_position - global_position
	var dir = diff.normalized() * speed * delta * sqrt(diff.length())
	if diff.length() >= dir.length():
		global_position += dir
	else:
		global_position += diff
