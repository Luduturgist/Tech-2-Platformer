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
			
			var local_lunge: Vector2 = lunge
			if enemy.pivot.scale.x < 0:
				local_lunge.x *= -1
			enemy.velocity += local_lunge
			
			enemy.play_sfx(enemy.attack_sfx)
	
	if attack_timer > 0 and enemy.health > 0:
		attack_timer -= delta
		if attack_timer <= 0:
			if enemy.is_multiplayer_authority():
				cooldown_timer = attack_interval + attack_timer
			attack_timer = 0
			enemy.end_attack.emit()
		elif not already_hit:
			_try_for_cast_damage()
	
	if not enemy.is_multiplayer_authority():
		return
	
	if cooldown_timer > 0:
		cooldown_timer -= delta
		if cooldown_timer >= 0:
			cooldown_timer = 0

func _try_for_cast_damage():
	if already_hit:
		return
	
	enemy.damage_cast.force_shapecast_update()
	var objects: Array = enemy.damage_cast.collision_result
	if not objects or not objects.size():
		return
	
	var players: Array[PlayerMovement]
	var blocking: Area2D = null
	for o in objects:
		var obj: Node2D = o.get("collider")
		#if obj.get_meta("Mortal"):
		if obj.get_script() == PlayerMovement:
			players.append(obj)
		elif obj.get_script() == Brace_Object:
			if not blocking:
				blocking = obj

	
	if blocking:
		var blocked: int = 0
		if players.size() > 0:
			var index_mod: int = 0
			for p in players.size():
				if (players[p+index_mod].global_position - enemy.global_position).length() > (blocking.global_position - enemy.global_position).length():
					players.remove_at(p+index_mod)
					blocked += 1
					index_mod -= 1
				else:
					blocked -= 1
				print(str(blocked))
				print("why")
		if enemy.is_multiplayer_authority():
			if blocked >= 0 or players.size() == 0:
				enemy.rpc("_network_stun")
		already_hit = true
	if players.size():
		for p in players:
			if p == Game_Scene.active.local:
				_damage_player(p)
