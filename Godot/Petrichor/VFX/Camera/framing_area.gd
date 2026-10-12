extends Camera_Area

@export var target: Node2D

func assign_camera_area():
	director.switch_cam(director.frame_cam)
	director.frame_cam.framing_target = target
	director.frame_cam.speed = track_speed
