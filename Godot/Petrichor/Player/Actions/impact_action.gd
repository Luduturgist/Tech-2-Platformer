extends Action
class_name Impact_Action

var cast: ShapeCast2D

func _start(m: PlayerMovement, sig = null):
	super._start(m, sig)
	cast = m.impact_caster

func _perform_action():
	var last_vel := move.last_velocity
	print(str(last_vel))
	var damage: int = 0
	var pause: float = 0
	
	if last_vel >= 275:
		# 1 tile's worth of velocity, ~280 falling to ~320 jumped
		damage = 1
	
	if last_vel >= 395:
		# 2 tile's worth of velocity, ~400 falling to ~410 jumped
		damage = 2
		pause = 0.12
	
	if last_vel >= 475:
		# 3 tile's worth of velocity, ~482 falling to ~480 jumped
		damage = 4
		pause = 0.2
	
	if last_vel >= 555:
		damage = 6
		pause = 0.4
	
	if damage > 0:
		basic_damage(damage)
	if pause > 0:
		PlayerInput._pause_movement(pause)
		move.velocity.x = move_toward(move.velocity.x, 0, move.move_speed)

func basic_damage(amount: int):
	move.impact_caster.force_shapecast_update()
	var objects: Array = move.impact_caster.collision_result
	if not objects or not objects.size():
		return
	for o in objects:
		if o.get("collider").get_script() == Enemy:
			o.get("collider")._take_damage(amount)
