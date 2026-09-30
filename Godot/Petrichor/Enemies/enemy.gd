extends CharacterBody2D
class_name Enemy

@export_group("Stats")
@export var health: int = 3
@export var damage: int = 3
@export var speed: float = 50
@export var accel: float = 250
@export var attack_range: float = 25
@export var stun_time: float = 3
@export var knockback: Vector2
@export var fall_speed: float = 30
@export var start_flipped: bool = false

@export_group("References")
@export var collider: CollisionShape2D
@export var detection_range: Area_Detector
@export var chase_range: Area_Detector
@export var override_detection_range: Area_Detector
@export var pivot: Node2D
@export var attack_behavior: EnemyAttackBehavior

signal damage_taken
signal stunned
signal killed
@warning_ignore("unused_signal")
signal start_attack
@warning_ignore("unused_signal")
signal end_attack
signal update_tracking(bool)
signal update_stun(bool)


var tracking_enemy: bool
var target: Node2D

func _ready() -> void:
	attack_behavior._start(self)
	
	if start_flipped:
		pivot.scale.x *= -1
	
	if multiplayer.is_server():
		if not detection_range:
			return
		detection_range.target_found.connect(track_target.bind(true))
		chase_range.target_lost.connect(track_target.bind(false))
		stunned.connect(knockback_enemy)
		override_detection_range.target_found.connect(override_target)

func knockback_enemy():
	velocity.x += knockback.x * sign(pivot.scale.x)
	velocity.y += knockback.y

func track_target(value: bool):
	print("target " + str(value))
	if target and chase_range.targets.find(target) != -1:
		return
	
	target = detection_range._nearest_target()
	
	print("happenings")
	tracking_enemy = not not target
	rpc("_network_tracking", tracking_enemy)

func override_target(new_target: Node2D = null):
	tracking_enemy = true
	
	if new_target == null:
		target = override_detection_range._nearest_target()
		if target == null:
			tracking_enemy = false
	else:
		target = new_target
	
	rpc("_network_tracking", tracking_enemy)


var last_pos: Vector2
func _physics_process(_delta: float) -> void:
	if not is_on_floor():
		velocity.y += fall_speed
	
	if last_pos != position and Wrapper.scene_synchronized:
		_update_position.rpc(position, pivot.scale.x)
		last_pos = position
	
	move_and_slide()

var stun_timer: float
func _process(delta: float) -> void:
	
	if stun_timer > 0:
		stun_timer -= delta
		if stun_timer <= 0:
			stun_timer = 0
			update_stun.emit(false)

func _take_damage(amount: int) -> int:
	rpc("_network_damage", amount, int(Wrapper.local_type))
	damage_taken.emit()
	return process_damage(amount, Wrapper.local_type)

func process_damage(amount: int, player: int) -> int:
	health -= amount
	if health <= 0:
		if is_multiplayer_authority():
			rpc("kill_enemy")
		amount += health
	
	if is_multiplayer_authority():
		if player == Wrapper.local_type:
			override_target(Game_Scene.active.local)
		else:
			override_target(Game_Scene.active.friend)
	
	return amount

@rpc("authority", "call_remote", "unreliable_ordered")
func _update_position(pos: Vector2, sca: int):
	position = pos
	pivot.scale.x = sca

@rpc("authority", "call_local", "reliable")
func _network_tracking(value: bool):
	update_tracking.emit(value)

@rpc("any_peer", "call_remote", "reliable")
func _network_damage(amount: int, player: int):
	damage_taken.emit()
	process_damage(amount, player)

@rpc("authority", "call_local", "reliable")
func _network_stun():
	stun_timer = stun_time
	update_stun.emit(true)
	stunned.emit()

@rpc("authority", "call_local", "reliable")
func kill_enemy():
	killed.emit()
	set_meta("Mortal", false)
	
	#queue_free()
