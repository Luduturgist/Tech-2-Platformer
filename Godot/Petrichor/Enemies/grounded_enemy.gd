extends Enemy
class_name Grounded_Enemy

signal start_attack
signal end_attack
@export var attack_feedback: Node2D
@export var attack_duration: float = 1
@export var attack_interval: float = 1.5

func _ready():
	super._ready()

func _physics_process(_delta: float) -> void:
	process_attack(_delta)
	
	if not is_multiplayer_authority():
		return
	
	if tracking_enemy and health > 0:
		var target: Vector2 = detection_range._nearest_target(global_position).global_position
		var diff: Vector2 = target - global_position
		if diff.length() <= attack_range and attack_timer == 0:
			if pivot.scale.x * diff.x < 0:
				pivot.scale.x *= -1
			rpc("_update_position", position, pivot.scale.x)
			rpc("perform_attack")
		elif attack_timer == 0 and diff.length() > attack_range:
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
func process_attack(delta: float):
	if attack_timer > 0:
		attack_timer -= delta
		if attack_timer <= 0:
			if is_multiplayer_authority():
				attack_timer = -attack_interval
			else:
				attack_timer = 0
			end_attack.emit()
	
	if not is_multiplayer_authority():
		return
	
	if attack_timer < 0:
		attack_timer += delta
		if attack_timer >= 0:
			attack_timer = 0

@rpc("authority", "call_local", "reliable")
func perform_attack():
	print("attacking")
	attack_timer = attack_duration
	attack_feedback.visible = true
	start_attack.emit()
	await end_attack
	attack_feedback.visible = false

func track_target(value: bool):
	super.track_target(value)
	if not value:
		attack_timer = false
