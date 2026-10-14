extends Enemy
class_name Grounded_Enemy


func _ready():
	super._ready()

func _physics_process(_delta: float) -> void:
	if attack_behavior:
		attack_behavior._update(_delta)
	
	if not is_multiplayer_authority():
		return
	
	if enemy_can_move() and attack_behavior.can_attack():
		var diff: Vector2 = target.global_position - global_position
		if diff.length() <= attack_range and not attack_behavior.is_attacking():
			if pivot.scale.x * diff.x < 0:
				pivot.scale.x *= -1
			rpc("_update_position", position, pivot.scale.x)
			if attack_behavior.can_attack():
				rpc("perform_attack")
		elif diff.length() > attack_range and not attack_behavior.is_attacking():
			follow_player(diff, _delta)
		else:
			velocity.x = move_toward(velocity.x, 0, accel * _delta)
	else:
		if attack_behavior.can_attack():
			try_swap_animation(0)
		velocity.x = move_toward(velocity.x, 0, accel * _delta)
	
	super._physics_process(_delta)

func follow_player(diff: Vector2, delta: float):
	if not is_multiplayer_authority():
		return
	
	var dir: Vector2 = diff.normalized()
	if abs(dir.x) > abs(diff.x):
		dir.x = diff.x
	velocity.x = move_toward(velocity.x, dir.x * speed, accel * delta)
	if dir.x * pivot.scale.x < 0:
		pivot.scale.x *= -1
	
	try_swap_animation(1)

func track_target(value: bool):
	super.track_target(value)
	#if not value:
		#attack_timer = false
