extends Game_Cam
class_name Locking_Cam

var confined_x: bool
var confined_y: bool
var confines: Vector2

var anchor: Node2D

func _physics_process(delta: float) -> void:
	if not is_current():
		return
	
	var clamped_follow: Vector2 = director.follow.global_position + custom_offset + director.director_offset
	
	if confined_x:
		clamped_follow.x = clampf(clamped_follow.x, anchor.global_position.x - confines.x + custom_offset.x, anchor.global_position.x + confines.x)
	if confined_y:
		clamped_follow.y = clampf(clamped_follow.y, anchor.global_position.y + confines.y, anchor.global_position.y - confines.y)
	
	global_position = soft_follow(delta, clamped_follow)

func smth_too_tired_sort_out_later_maybe(delta: float, target_pos: Vector2) -> Vector2:
		var diff = target_pos - global_position + custom_offset + director.director_offset
		
		var clamped_follow: Vector2 = target_pos + custom_offset
		clamped_follow.x = clampf(clamped_follow.x, anchor.global_position.x - confines.x + custom_offset.x, anchor.global_position.x + confines.x)
		clamped_follow.y = clampf(clamped_follow.y, anchor.global_position.y - confines.y + custom_offset.y, anchor.global_position.y + confines.y)
		var confined_diff = clamped_follow - global_position + custom_offset + director.director_offset
		
		var calc_pos: Vector2
		
		if confined_x:
			calc_pos.x = move_toward(global_position.x, clamped_follow.x, delta * speed)
		else:
			calc_pos.x = move_toward(global_position.x, target_pos.x + custom_offset.x + director.director_offset.x, speed * delta * abs(diff.normalized().x))
		
		if confined_y:
			calc_pos.y = move_toward(global_position.y, clamped_follow.y, delta * speed * abs(confined_diff.normalized().x))
		else:
			calc_pos.y = move_toward(global_position.y, target_pos.y + custom_offset.y + director.director_offset.y, speed * delta * abs(diff.normalized().y))
		
		return calc_pos
