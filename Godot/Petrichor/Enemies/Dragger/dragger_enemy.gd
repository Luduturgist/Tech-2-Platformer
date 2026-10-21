extends Enemy
class_name Dragger_Enemy

@export_category("Dragging")
@export var drag_duration: float = 1
@export var drag_interval: float = 1

func _physics_process(_delta: float) -> void:
	if attack_behavior:
		attack_behavior._update(_delta)
	
	if not is_multiplayer_authority():
		return
	
	if drag_timer < 0:
		drag_timer += _delta
		if drag_timer >= 0:
			drag_timer = 0
	
	if enemy_can_move() and drag_timer >= 0 and attack_behavior.can_attack():
		var diff: Vector2 = target.global_position - global_position
		if diff.length() <= attack_range and not attack_behavior.is_attacking():
			if pivot.scale.x * diff.x < 0:
				pivot.scale.x *= -1
			rpc("_update_position", position, pivot.scale.x)
			if attack_behavior.can_attack():
				rpc("perform_attack")
				print("attacking")
				try_swap_animation(2)
		elif diff.length() > attack_range and not attack_behavior.is_attacking():
			follow_player(diff, _delta)
		else:
			velocity.x = move_toward(velocity.x, 0, accel * _delta)
	else:
		if attack_behavior.is_attacking() or drag_timer == 0:
			try_swap_animation(0)
		velocity.x = move_toward(velocity.x, 0, accel * _delta)
	
	super._physics_process(_delta)

var drag_timer: float
func follow_player(diff: Vector2, delta: float):
	if not is_multiplayer_authority():
		return
	
	if drag_timer == 0:
		drag_timer = drag_duration
		try_swap_animation(1)
	
	if drag_timer > 0:
		try_swap_animation(1)
	
	var dir: Vector2 = diff.normalized()
	if abs(dir.x) > abs(diff.x):
		dir.x = diff.x
	velocity.x = move_toward(velocity.x, dir.x * speed, accel * delta / drag_timer)
	if dir.x * pivot.scale.x < 0:
		pivot.scale.x *= -1
	
	drag_timer -= delta
	if drag_timer <= 0:
		drag_timer = -drag_interval
		#try_swap_animation(0)
