extends Action
class_name Impact_Action

var cast: ShapeCast2D

func _start(m: PlayerMovement, sig = null):
	super._start(m, sig)
	cast = m.impact_cast

func _perform_action():
	var last_vel = move.last_velocity
	basic_damage()
	if last_vel <= 0:
		return
	elif last_vel > 375:
		pass
	elif last_vel > 1000:
		pass

func basic_damage():
	print("casting")
	cast.force_shapecast_update()
	var objects: Array = cast.collision_result
	if not objects.size():
		return
	print(str(objects.size()))
	for o in objects:
		if o.get("collider").get_script() == Enemy:
			print("enemy found")
			o.get("collider")._take_damage(1)
