extends Enemy
class_name Grounded_Enemy

signal start_attack
signal end_attack
@export var attack_feedback: Node2D
@export var attack_delay: float = 0.5
@export var attack_duration: float = 1
@export var attack_interval: float = 0.5
@export var damage_cast: ShapeCast2D

func _ready():
	super._ready()
	killed.connect(func(): attack_feedback.visible = false)

func _physics_process(_delta: float) -> void:
	process_attack(_delta)
	
	if not is_multiplayer_authority():
		return
	
	if tracking_enemy and health > 0:
		var target: Vector2 = detection_range._nearest_target(global_position).global_position
		var diff: Vector2 = target - global_position
		if diff.length() <= attack_range and attack_timer == 0 and windup == 0:
			if pivot.scale.x * diff.x < 0:
				pivot.scale.x *= -1
			rpc("_update_position", position, pivot.scale.x)
			rpc("perform_attack")
		elif attack_timer == 0 and diff.length() > attack_range and windup == 0:
			follow_player(diff, _delta)
		else:
			velocity.x = move_toward(velocity.x, 0, accel * _delta)
			move_and_slide()
	
	super._physics_process(_delta)

func follow_player(diff: Vector2, delta: float):
	if not is_multiplayer_authority():
		return
	
	var dir: Vector2 = diff.normalized()
	if abs(dir.x) > abs(diff.x):
		dir.x = diff.x
	velocity.x = move_toward(velocity.x, dir.x * speed, accel * delta)
	if velocity.x * pivot.scale.x < 0:
		pivot.scale.x *= -1
	move_and_slide()

var attack_timer: float
var windup: float
func process_attack(delta: float):
	if windup > 0 and health > 0:
		windup -= delta
		if windup <= 0:
			attack_timer = attack_duration + windup
			windup = 0
			start_attack.emit()
	
	if attack_timer > 0 and health > 0:
		attack_timer -= delta
		if attack_timer <= 0:
			if is_multiplayer_authority():
				attack_timer = -attack_interval
			else:
				attack_timer = 0
			end_attack.emit()
		elif not already_hit and health > 0:
			_try_for_cast_damage()
	
	if not is_multiplayer_authority():
		return
	
	if attack_timer < 0:
		attack_timer += delta
		if attack_timer >= 0:
			attack_timer = 0

@rpc("authority", "call_local", "reliable")
func perform_attack():
	windup = attack_delay
	await start_attack
	attack_feedback.visible = true
	damage_cast.enabled = true
	await end_attack
	damage_cast.enabled = false
	attack_feedback.visible = false
	already_hit = false

func track_target(value: bool):
	super.track_target(value)
	if not value:
		attack_timer = false

var already_hit: bool = false
func _try_for_cast_damage():
	var objects: Array = damage_cast.collision_result
	if not objects or not objects.size():
		return
	
	var player: PlayerMovement
	var blocking: Area2D
	for o in objects:
		var obj: Node2D = o.get("collider")
		if obj.get_meta("Mortal"):
			if obj.get_script() == PlayerMovement:
				player = obj
			elif obj.get_script() == Brace_Object:
				blocking = obj
	
	if player:
		if blocking:
			if (player.global_position - global_position) <= (blocking.global_position - global_position):
				return
		player._take_damage(damage)
		already_hit = true
