extends Action
class_name Impact_Action

var cast: ShapeCast2D

func _start(m: PlayerMovement, sig = null):
	super._start(m, sig)
	cast = m.impact_caster

func _perform_action():
	var last_vel := move.last_velocity
	print(str(last_vel))
	if last_vel > 275:
		# 1 tile's worth of velocity, ~280 falling to ~320 jumped
		basic_damage()
	elif last_vel > 395:
		# 2 tile's worth of velocity, ~400 falling to ~410 jumped
		pass
	elif last_vel > 475:
		# 3 tile's worth of velocity, ~482 falling to ~480 jumped
		pass

func basic_damage():
	move.impact_caster.force_shapecast_update()
	var objects: Array = move.impact_caster.collision_result
	if not objects.size():
		return
	for o in objects:
		if o.get("collider").get_script() == Enemy:
			o.get("collider")._take_damage(1)
