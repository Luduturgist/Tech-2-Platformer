extends Area2D
class_name Ladder_Area

@export var climbing_speed: float = 80
@export var cooldown: float = 0.2
@export var upper_limit: Node2D
@export var lower_limit: Node2D

var listening: bool
var climbing: bool
var player: PlayerMovement

func _ready():
	body_entered.connect(listen_to_player.bind(true))
	body_exited.connect(listen_to_player.bind(false))
	PlayerInput.player_vertical_pressed.connect(start_climb)
	PlayerInput.player_jump.connect(start_climb.bind(false))
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
	
	#print("laddering")
	
	var within_limits: bool
	within_limits = player.global_position.y <= lower_limit.global_position.y and player.global_position.y >= upper_limit.global_position.y
	
	if PlayerInput.player_movement.y != 0 and listening and not climbing and cooldown_timer == 0:
		start_climb()
	
	if climbing and within_limits:
		player.velocity = Vector2(0, -PlayerInput.player_movement.y * climbing_speed)
		player.move_and_slide()
		#print("movvign")
	
	within_limits = player.global_position.y >= lower_limit.global_position.y and player.global_position.y <= upper_limit.global_position.y
	
	if climbing and not within_limits:
		if player.global_position.y > lower_limit.global_position.y:
			player.global_position.y = lower_limit.global_position.y
		elif player.global_position.y < upper_limit.global_position.y:
			player.global_position.y = upper_limit.global_position.y
	
	if player.velocity.y != 0:
		player.rpc("_network_position", player.global_position, player.pivot.scale.x == -1)

func listen_to_player(body: Node2D, value: bool):
	if body is PlayerMovement and body.local:
		player = body
		listening = value
		if not value:
			bail()

var climb_started: bool = false
func start_climb(automatic: bool = true):
	if not automatic:
		automatic = not PlayerMovement.active.is_on_floor()
	
	if listening and not climbing and cooldown_timer == 0 and automatic:
		player.using_gravity = false
		climb_started = true
		climbing = true
		player.global_position.x = global_position.x
		player.velocity = Vector2.ZERO
		player.taking_action = true
		player.change_animation(&"Idle")
		player.rpc("_network_position", player.global_position, player.pivot.scale.x)

func bail():
	if climb_started:
		climb_started = false
	elif climbing:
		climbing = false
		player.using_gravity = true
		player.process_jump(true)
		cooldown_timer = cooldown
		player.taking_action = false
