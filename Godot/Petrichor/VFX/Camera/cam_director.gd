extends Node2D
class_name Cam_Director

@export var follow: Node2D
@export var peek_speed: float = 300
@export var peek_return: float = 400
@export var peek_distance: float = 100
@export var peek_accel: float = 10
@export var peek_smoothing: float = 0.6
@export var look_speed: float = 200
@export var lookahead: float = 10
@export var look_buffer: float = 20

@export_category("Cameras")
@export var follow_cam: TrackingCam
@export var frame_cam: Framing_Cam
@export var locking_cam: Locking_Cam

var active_cam: Game_Cam
var director_offset: Vector2
var peek_velocity: float
var lookahead_velocity: float
var waiting_cam_area: Camera_Area
var active_cam_area: Camera_Area

@warning_ignore("unused_signal")
signal camera_area_exited

func switch_cam(cam: Game_Cam):
	cam.follow = follow
	cam._camera_start(active_cam.global_position)
	active_cam = cam

func _enter_camera_area(area: Camera_Area):
	if active_cam_area == null:
		active_cam_area = area
		area.assign_camera_area()
	else:
		waiting_cam_area = area
		print("shoudln't happen")

func _exit_camera_area(area: Camera_Area):
	if area == active_cam_area:
		if waiting_cam_area:
			active_cam_area = waiting_cam_area
			active_cam_area.assign_camera_area()
			waiting_cam_area = null
		else:
			active_cam_area = null
			switch_cam(follow_cam)
			follow_cam.velocity = Vector2.ZERO
			print("Switching back")
	
	elif area == waiting_cam_area:
		waiting_cam_area = null


func _ready() -> void:
	var children := get_children()
	for child in children.size():
		if children[child] == Game_Cam:
			children[child].follow = follow
			children[child].director = self

func _activate_camera(obj: Node2D):
	follow = obj
	active_cam = follow_cam
	active_cam.follow = obj
	await get_tree().process_frame
	active_cam._camera_start()

var cam_delay: float = 0.2
var cam_delay_timer: float = 0.2
var last_input: int = 0
func _physics_process(delta: float) -> void:
	if active_cam:
		process_peek(delta)
		process_lookahead(delta)

var last_pos: Vector2
var last_input_x: int = 1
func process_lookahead(delta: float):
	#var diff := last_pos.x - follow.global_position.x
	#lookahead_velocity = move_toward(lookahead_velocity, diff - sign(diff) * lookahead, delta * look_speed * abs(diff))
	
	if PlayerInput.player_movement.x != 0:
		last_input_x = sign(PlayerInput.player_movement.x)
	
	lookahead_velocity = move_toward(lookahead_velocity, sign(PlayerInput.player_movement.x) * lookahead + look_buffer * last_input_x, delta * look_speed)
	
	director_offset.x = lookahead_velocity
	
	last_pos = follow.global_position

func process_peek(delta: float):
	var can_peek: bool = true
	if active_cam_area:
		can_peek = active_cam_area.can_peek
	
	if PlayerInput.player_movement.y != 0 and PlayerInput.player_movement.x == 0 and Game_Scene.active.local.is_on_floor() and can_peek:
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
