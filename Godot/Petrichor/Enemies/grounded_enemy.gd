extends Enemy
class_name Grounded_Enemy

@export var attack_feedback: Node2D
@export var damage_cast: ShapeCast2D

func _ready():
	super._ready()
	killed.connect(func(): attack_feedback.visible = false)

func _physics_process(_delta: float) -> void:
	attack_behavior._update(_delta)
	
	if not is_multiplayer_authority():
		return
	
	if tracking_enemy and health > 0:
		var target: Vector2 = detection_range._nearest_target(global_position).global_position
		var diff: Vector2 = target - global_position
		if diff.length() <= attack_range and not attack_behavior.is_attacking():
			if pivot.scale.x * diff.x < 0:
				pivot.scale.x *= -1
			rpc("_update_position", position, pivot.scale.x)
			rpc("perform_attack")
		elif diff.length() > attack_range and not attack_behavior.is_attacking():
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

@rpc("authority", "call_local", "reliable")
func perform_attack():
	attack_behavior._attack_start()
	await end_attack
	attack_behavior._attack_end()

func track_target(value: bool):
	super.track_target(value)
	#if not value:
		#attack_timer = false
