extends Camera_Area
class_name Locking_Cam_Area

@export var confine_x: bool
@export var confine_y: bool
@export var anchor: Node2D
@export var confine_distance: Vector2


func assign_camera_area():
	var cam := director.locking_cam
	cam.confines = confine_distance
	director.switch_cam(cam)
	cam.confined_x = confine_x
	cam.confined_y = confine_y
	cam.anchor = anchor
	cam.speed = track_speed
