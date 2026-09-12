@icon("res://Player/Soil/Soil.png")
extends CharacterBody2D
class_name PlayerMovement

@export_group("Settings")
@export var move_speed: float = 100
@export var accel: float = 800
@export var jump: float = 280
@export var fallSpeed: int = 1200
@export var energy: PlayerEnergy

@export_group("Actions")
@export var friendly: Action
@export var pain_feedback: Action
@export var move_ability: Action
@export var brace: Action
@export var impact_action: Action
var taking_action: bool = false

@export_group("References")
@export var pivot: Node2D
@export var collider: CollisionShape2D
@export var network_sync: MultiplayerSynchronizer
@export var cam_offset: Node2D
@export var impact_caster: ShapeCast2D
@export var push_cast: ShapeCast2D

static var active: PlayerMovement
var local: bool
@warning_ignore("unused_signal")
signal interact
@warning_ignore("unused_signal")
signal special_interact
signal player_land
var speed_mods: Dictionary[String, float]
var cheering: bool = false

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
	Wrapper.scene_ready.connect(_set_network_visibility.bind(0))
	multiplayer.peer_disconnected.connect(_set_network_visibility)
	PlayerInput.player_debug.connect(_debug)
	

func _set_network_visibility(i: int):
	await get_tree().process_frame
	network_sync.public_visibility = not i

func dress() -> void:
	cam_offset_init = cam_offset.position
	cam_offset.position = Vector2.ZERO
	#print(name + " dressed by " + str(multiplayer.get_unique_id()))
	active = self
	local = true
	
	set_collision_layer_value(2, false)
	set_collision_layer_value(1, true)
	set_collision_layer_value(5, true)
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

func _debug():
	var _s: String = "local "
	if not local:
		_s = "friend "
	#print(_s + "golem owned by " + str(get_multiplayer_authority()))

func _take_damage(amount: int = 1):
	if not local: return
	if amount > 0: pain_feedback._perform_action()
	energy._inflict_pain(amount)

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
	
	if not local: return
	
	move_ability._update(delta)
	
	process_move(delta)
	process_camera_offset(delta)
	energy._update(delta)

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
		velocity.x = move_toward(velocity.x, dir.x * speed, accel * delta)
		if dir.x * pivot.scale.x < 0:
			pivot.scale.x *= -1
			collider.position.x *= -1
	elif is_on_floor():
		var drag := (accel + velocity.x / move_speed) * delta
		velocity.x = move_toward(velocity.x, 0, drag)
		
	var was_grounded = is_on_floor()
	last_velocity = velocity.length()
	move_and_slide()
	if not was_grounded and is_on_floor():
		player_land.emit()
		impact_action._perform_action()
		if last_velocity > 375:
			$Pivot/Dust._trigger_event()

func process_camera_offset(_delta: float):
	pass
	#cam_offset.position.x = cam_offset_init.x * (0.5 + (PlayerInput.player_movement.x / 2))
