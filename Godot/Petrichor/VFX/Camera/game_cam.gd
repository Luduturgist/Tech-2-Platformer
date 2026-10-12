extends Camera2D
class_name Game_Cam

@export var custom_offset: Vector2

var director: Cam_Director
var follow: Node2D

func _camera_start(transfer: Vector2 = Vector2.INF):
	director = get_parent()
	
	if transfer != Vector2.INF:
		global_position = transfer
	elif follow:
		global_position = follow.global_position
	
	make_current()
