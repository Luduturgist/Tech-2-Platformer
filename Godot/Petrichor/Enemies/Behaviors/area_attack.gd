extends EnemyAttackBehavior
class_name Area_Attack

var damage_feedback: Node2D
var damage_cast: ShapeCast2D

func _start(e: Enemy):
	super._start(e)

func _attack_start():
	windup = attack_delay

func _attack_end():
	enemy.attack_feedback.visible = false
	enemy.damage_cast.enabled = false
	already_hit = false

func _update(delta: float):
	if windup > 0 and enemy.health > 0:
		windup -= delta
		if windup <= 0:
			attack_timer = attack_duration + windup
			windup = 0
			enemy.start_attack.emit()
			enemy.attack_feedback.visible = true
			enemy.damage_cast.enabled = true
	
	if attack_timer > 0 and enemy.health > 0:
		attack_timer -= delta
		if attack_timer <= 0:
			if enemy.is_multiplayer_authority():
				attack_timer = -attack_interval
			else:
				attack_timer = 0
			enemy.end_attack.emit()
		elif not already_hit and enemy.health > 0:
			_try_for_cast_damage()
	
	if not enemy.is_multiplayer_authority():
		return
	
	if attack_timer < 0:
		attack_timer += delta
		if attack_timer >= 0:
			attack_timer = 0

var already_hit: bool = false
func _try_for_cast_damage():
	var objects: Array = enemy.damage_cast.collision_result
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

	
	if blocking:
		if (Game_Scene.active.local.global_position - enemy.global_position).length() > (blocking.global_position - enemy.global_position).length() or enemy.is_multiplayer_authority():
			if enemy.is_multiplayer_authority():
				enemy.rpc("_network_stun")
			return
	if player:
		player._take_damage(damage)
		already_hit = true
