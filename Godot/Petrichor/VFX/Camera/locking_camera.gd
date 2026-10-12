extends Game_Cam
class_name Locking_Cam

@export var speed: float = 250

var confined_x: bool
var confined_y: bool
var confines: Vector2

var anchor: Node2D

func _physics_process(delta: float) -> void:
	if is_current():
		var diff = director.follow.global_position - global_position + custom_offset + director.director_offset
		
		var clamped_follow: Vector2 = director.follow.global_position + custom_offset
		clamped_follow.x = clampf(clamped_follow.x, anchor.global_position.x - confines.x + custom_offset.x, anchor.global_position.x + confines.x)
		clamped_follow.y = clampf(clamped_follow.y, anchor.global_position.y - confines.y + custom_offset.y, anchor.global_position.y + confines.y)
		var confined_diff = clamped_follow - global_position + custom_offset + director.director_offset

		
		
		if confined_x:
			global_position.x = move_toward(global_position.x, clamped_follow.x, delta * speed)
		else:
			global_position.x = move_toward(global_position.x, director.follow.global_position.x + custom_offset.x + director.director_offset.x, speed * delta * abs(diff.normalized().x))
		
		if confined_y:
			global_position.y = move_toward(global_position.y, clamped_follow.y, delta * speed * abs(confined_diff.normalized().x))
		else:
			global_position.y = move_toward(global_position.y, director.follow.global_position.y + custom_offset.y + director.director_offset.y, speed * delta * abs(diff.normalized().y))
