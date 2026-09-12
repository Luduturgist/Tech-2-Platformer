extends Action
class_name Impact_Action

var cast: ShapeCast2D

func _start(m: PlayerMovement, sig = null):
	super._start(m, sig)
	cast = m.impact_caster

func _perform_action():
	var last_vel := move.last_velocity
	print(str(last_vel))
	if 275 <= last_vel and last_vel < 395:
		# 1 tile's worth of velocity, ~280 falling to ~320 jumped
		basic_damage(1)
	elif 395 <= last_vel and last_vel < 475:
		# 2 tile's worth of velocity, ~400 falling to ~410 jumped
		basic_damage(2)
	elif 475 <= last_vel:
		# 3 tile's worth of velocity, ~482 falling to ~480 jumped
		basic_damage(3)

func basic_damage(amount: int):
	move.impact_caster.force_shapecast_update()
	var objects: Array = move.impact_caster.collision_result
	if not objects or not objects.size():
		return
	for o in objects:
		if o.get("collider").get_script() == Enemy:
			o.get("collider")._take_damage(amount)
