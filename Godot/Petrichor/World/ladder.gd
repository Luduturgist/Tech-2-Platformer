extends Area2D
class_name Ladder_Area

@export var climbing_speed: float = 4000
@export var cooldown: float = 0.2

var listening: bool
var climbing: bool
var player: PlayerMovement

func _ready():
	body_entered.connect(listen_to_player.bind(true))
	body_exited.connect(listen_to_player.bind(false))
	PlayerInput.player_vertical_pressed.connect(start_climb)
	PlayerInput.player_jump.connect(start_climb)
	PlayerInput.player_jump.connect(bail)

var cooldown_timer: float
func _physics_process(delta: float) -> void:
	climb_started = false
	if cooldown_timer > 0:
		cooldown_timer -= delta
		if cooldown_timer <= 0:
			cooldown_timer = 0
	
	if not listening:
		return
	
	print("laddering")
	
	if climbing:
		player.using_gravity = false
		player.velocity = Vector2(0, -PlayerInput.player_movement.y * delta * climbing_speed)
		player.move_and_slide()

func listen_to_player(body: Node2D, value: bool):
	if body is PlayerMovement and body.local:
		player = body
		listening = value
		if not value:
			bail()

var climb_started: bool = false
func start_climb():
	if listening and not climbing and cooldown_timer == 0:
		climb_started = true
		climbing = true
		player.global_position.x = global_position.x
		player.velocity = Vector2.ZERO
		player.taking_action = true

func bail():
	if climb_started:
		climb_started = false
	elif climbing:
		climbing = false
		player.using_gravity = true
		player.process_jump(true)
		cooldown_timer = cooldown
		player.taking_action = false
