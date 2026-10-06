extends Node2D
class_name Cam_Director

@export var follow: Node2D
@export var active_cam: Game_Cam
@export var peek_speed: float = 300
@export var peek_return: float = 400
@export var peek_distance: float = 100
@export var peek_accel: float = 10
@export var peek_smoothing: float = 0.6

var director_offset: Vector2
var peek_velocity: float

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

var cam_delay: float = 0.2
var cam_delay_timer: float = 0.2
var last_input: int = 0
func _physics_process(delta: float) -> void:
	if PlayerInput.player_movement.y != 0 and PlayerInput.player_movement.x == 0 and Game_Scene.active.local.is_on_floor():
		if PlayerInput.controller_input:
			peek(delta)
		else:
			if last_input != sign(PlayerInput.player_movement.y) and director_offset.y == 0:
				cam_delay_timer = cam_delay
				last_input = sign(PlayerInput.player_movement.y)
			else:
				if cam_delay_timer > 0:
					cam_delay_timer -= delta
				
				if cam_delay_timer <= 0 or director_offset.y == 0:
					peek(delta)
	
	elif director_offset.y != 0:
		unpeek(delta)
		if director_offset.y == 0:
			cam_delay_timer = cam_delay


var buffer: float = 2
func peek(delta: float):
	director_offset.y = move_toward(director_offset.y, -sign(PlayerInput.movement_raw.y) * peek_distance, delta * peek_speed)

func unpeek(delta):
	director_offset.y = move_toward(director_offset.y, 0, delta * peek_return)
