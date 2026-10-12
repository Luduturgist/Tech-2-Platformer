@abstract

extends Area2D
class_name Camera_Area

@export var track_speed: float = 550
@export var can_peek: bool = false

var director: Cam_Director

func _ready() -> void:
	await get_tree().process_frame
	director = Game_Scene.active.camera
	body_entered.connect(_check_player)
	body_exited.connect(_dismiss_player)

func _check_player(body: Node2D):
	if body == director.follow:
		director._enter_camera_area(self)

func _dismiss_player(body: Node2D):
	if body == director.follow:
		director._exit_camera_area(self)

@abstract
func assign_camera_area()
