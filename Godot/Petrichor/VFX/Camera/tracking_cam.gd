extends Game_Cam
class_name TrackingCam



func _camera_start(transfer: Vector2 = Vector2.INF):
	super._camera_start()
	if transfer != Vector2.INF:
		global_position = transfer

func _physics_process(delta: float) -> void:
	if not director or not is_current():
		return
	
	global_position = velocity_follow(delta, follow.global_position +  custom_offset + director.director_offset)
