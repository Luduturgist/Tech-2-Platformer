extends Node2D
class_name Cam_Director

@export var follow: Node2D
@export var active_cam: Game_Cam

var director_offset: Vector2

func _ready() -> void:
	var children := get_children()
	for child in children.size():
		if children[child] == Game_Cam:
			children[child].follow = follow
			children[child].director = self

func _activate_camera():
	active_cam.follow = follow
	active_cam.make_current()
	active_cam._camera_start()
	
