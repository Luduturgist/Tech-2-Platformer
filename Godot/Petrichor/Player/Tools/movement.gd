@icon("res://Player/Soil/Soil.png")
extends CharacterBody2D
class_name PlayerMovement

@export_group("Settings")
@export var move_speed: float = 100
@export var accel: float = 800
@export var jump: float = 280
@export var fallSpeed: int = 1200
@onready var fall_truth = fallSpeed
@export var aerial_multiplier: float = 0.5
@export var energy: PlayerEnergy
@export var knockback: Vector2 = Vector2(-50, -50)

@export_group("Actions")
@export var friendly: Action
@export var pain_feedback: Action
@export var move_ability: Action
@export var brace: Action
@export var impact_action: Action
@export var attack: Action
var taking_action: bool = false

@export_group("References")
@export var pivot: Node2D
@export var collider: CollisionShape2D
@export var cam_offset: Node2D
@export var impact_caster: ShapeCast2D
@export var push_cast: ShapeCast2D
@export var animator: AnimatedSprite2D
@export var audio_player: AudioStreamPlayer2D
@export var impact_feedback: Array[Flash_Object]

static var active: PlayerMovement
var local: bool
@warning_ignore("unused_signal")
signal interact
@warning_ignore("unused_signal")
signal special_interact
signal player_land
var speed_mods: Dictionary[String, float]
var cheering: bool = false
var playback: AudioStreamPlaybackPolyphonic

var gravity_delay_timer: float = 0
func _delay_gravity(time: float):
	if time > gravity_delay_timer:
		gravity_delay_timer = time
	fallSpeed = 0

func sum_speed_mods() -> float:
	var sum: float = 0
	if speed_mods.size() > 0:
		for mod in speed_mods.values():
			sum *= mod
	else:
		return 1
	return sum

var cam_offset_init: Vector2
func _ready() -> void:
	if friendly: friendly._start(self)
	if pain_feedback: pain_feedback._start(self)
	PlayerInput.player_debug.connect(_debug)
	audio_player.play()
	playback = audio_player.get_stream_playback()

func dress() -> void:
	cam_offset_init = cam_offset.position
	cam_offset.position = Vector2.ZERO
	#print(name + " dressed by " + str(multiplayer.get_unique_id()))
	active = self
	local = true
	
	set_collision_layer_value(2, false)
	set_collision_layer_value(1, true)
	set_collision_mask_value(2, false)
	set_collision_mask_value(1, true)
	set_collision_mask_value(5, true)
	visibility_layer = 1
	z_index += 1
	set_meta(Game_Scene.COMBAT_METADATA, true)
	
	if energy == null:
		energy = PlayerEnergy.new()
	energy._start(self)
	move_ability._start(self, PlayerInput.player_special_movement)
	friendly._start(self, PlayerInput.player_interact)
	PlayerInput.player_debug.connect(energy._debug)
	brace._start(self, PlayerInput.player_brace)
	PlayerInput.player_jump.connect(process_jump)
	impact_action._start(self)
	attack._start(self, PlayerInput.player_attack_priveliged)

func _debug():
	var _s: String = "local "
	if not local:
		_s = "friend "
	#print(_s + "golem owned by " + str(get_multiplayer_authority()))

func _take_damage(amount: int = 1, source: float = INF):
	if not local:
		return
	
	if amount > 0: pain_feedback._perform_action()
	energy._inflict_pain(amount)
	if source != INF:
		var dir = sign(source - global_position.x)
		var knockback_local: Vector2 = Vector2(knockback.x * dir, knockback.y)
		velocity += knockback_local

func player_die():
	Wrapper._load_scene(get_tree().current_scene.scene_file_path)

var can_jump: bool = true
func process_jump():
	if is_on_floor() and can_jump:
		velocity.y = -jump * sum_speed_mods()

func _physics_process(delta: float) -> void:
	if friendly:
		friendly._update(delta)
	if pain_feedback:
		pain_feedback._update(delta)
	brace._update(delta)
	
	if not local:
		if network_position != Vector2.INF:
			var diff = network_position - global_position
			var dir = diff.normalized() * move_speed
			
			velocity.x = move_toward(velocity.x, dir.x, accel * delta)
			velocity.y = move_toward(velocity.y, dir.y, accel * delta)
			
			if abs(velocity.x) > abs(diff.x):
				velocity.x = 0
				global_position.x = network_position.x
			if abs(velocity.y) > abs(diff.y):
				velocity.y = 0
				global_position.y = network_position.y
			
			var smoothing: float = 50
			velocity.x = move_toward(velocity.x, 0, smoothing * delta)
			velocity.y = move_toward(velocity.y, 0, smoothing * delta)
			
			
			move_and_slide()
		return
	
	move_ability._update(delta)
	
	process_move(delta)
	process_camera_offset(delta)
	energy._update(delta)
	attack._update(delta)
	
	if gravity_delay_timer > 0:
		gravity_delay_timer -= delta
		if gravity_delay_timer <= 0:
			gravity_delay_timer = 0
			fallSpeed = fall_truth

var last_velocity: float = 0
var can_move: bool = true
func process_move(delta: float):	
	if not is_on_floor():
		velocity += fallSpeed * Vector2.DOWN * delta
		if velocity.y > jump * 2:
			velocity.y = jump * 2
	
	var dir := Vector2(PlayerInput.player_movement.x, 0)
	
	var speed = move_speed
	if speed_mods.size() > 0:
		for m in speed_mods.values():
			dir *= m
	
	if dir and can_move:
		var accel_modified: float = accel
		if not is_on_floor():
			accel_modified *= aerial_multiplier
		velocity.x = move_toward(velocity.x, dir.x * speed, accel_modified * delta)
		if dir.x * pivot.scale.x < 0 and not brace.fx.visible:
			pivot.scale.x *= -1
			collider.position.x *= -1
	elif is_on_floor():
		var drag: float = (accel + velocity.x / move_speed) * delta # * fallSpeed / fall_truth
		velocity.x = move_toward(velocity.x, 0, drag)
		
	var was_grounded = is_on_floor()
	last_velocity = velocity.length()
	move_and_slide()
	
	if not is_multiplayer_authority():
		return
	
	if Wrapper.scene_synchronized:
		rpc("_network_position", global_position, pivot.scale.x == -1)
	
	if not is_on_floor():
		if was_grounded:
			change_animation(&"Jump")
	elif velocity.x == 0:
		change_animation(&"Idle")
	elif PlayerInput.player_movement.x != 0:
		change_animation(&"Run")
	
	if not was_grounded and is_on_floor():
		player_land.emit()
		impact_action._perform_action()

func process_camera_offset(_delta: float):
	pass
	#cam_offset.position.x = cam_offset_init.x * (0.5 + (PlayerInput.player_movement.x / 2))

func change_animation(_name: StringName):
	if animator.animation != _name:
		animator.animation = _name
		rpc("network_animation", _name)

@rpc("authority", "call_remote", "reliable")
func network_animation(_name: StringName):
	animator.animation = _name

var network_position: Vector2 = Vector2.INF
@rpc("authority", "call_remote", "unreliable")
func _network_position(pos: Vector2, flipped: bool):
	network_position = pos
	var flip = 1
	if flipped:
		flip = -1
	pivot.scale.x = flip
	#moving_networked = dir
