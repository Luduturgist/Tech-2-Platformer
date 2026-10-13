extends Game_Cam
class_name Framing_Cam

@export var smoothing: float = 2

var framing_target: Node2D

func _ready() -> void:
	speed = 10

func _physics_process(delta: float) -> void:
	if is_current():
		var diff = framing_target.global_position - global_position + custom_offset + director.director_offset
		
		global_position.x = move_toward(global_position.x, framing_target.global_position.x + custom_offset.x, speed * delta * abs(diff.normalized().x))
		global_position.y = move_toward(global_position.y, framing_target.global_position.y + custom_offset.y, speed * delta * abs(diff.normalized().y))
		
