extends Action
class_name Impact_Action

var cast: ShapeCast2D
@export var height_buffer: float = 25

func _start(m: PlayerMovement, sig = null):
	super._start(m, sig)
	cast = m.impact_caster

func _perform_action():
	var last_vel := move.last_velocity + height_buffer
	#print(str(last_vel))
	var damage: int = 0
	var pause: float = 0
	var vfx: int = -1
	#var charge: float = 0
	
	if last_vel >= 275:
		# 1 tile's worth of velocity, ~280 falling to ~320 jumped
		pass
	
	if last_vel >= 395:
		# 2 tile's worth of velocity, ~400 falling to ~410 jumped
		damage = 1
		pause = 0.12
		vfx = 0
	
	if last_vel >= 475:
		# 3 tile's worth of velocity, ~482 falling to ~480 jumped
		damage = 2
		pause = 0.2
		vfx = 1
	
	if last_vel >= 555:
		damage = 4
		pause = 0.4
		vfx = 2
	
	if damage > 0:
		damage = basic_damage(damage)
	if pause > 0:
		PlayerInput._pause_movement(pause)
		move.velocity.x = move_toward(move.velocity.x, 0, move.move_speed)
	if damage > 0:
		move.energy._replenish_charge(damage)
	if vfx >= 0:
		move.impact_feedback[vfx]._trigger_event()

func basic_damage(amount: int) -> int:
	var dmg: int = 0
	move.impact_caster.force_shapecast_update()
	var objects: Array = move.impact_caster.collision_result
	if not objects or not objects.size():
		return dmg
	for o in objects:
		if o.get("collider").get_meta("Mortal"):
			dmg += o.get("collider")._take_damage(amount, move.global_position.x)
	return dmg
