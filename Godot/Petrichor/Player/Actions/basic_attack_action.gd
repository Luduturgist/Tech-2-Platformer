extends Action
class_name BasicAttack_Action

@export var starting_charge: int = 1
@export var windup: float = 0.4
@export var attack_duration: float = 0.3
@export var buffer: float = 0.3
@export var cooldown: float = 0.3
@export var attack_vfx_path: NodePath
@export var windupvfx_path: NodePath
@export var caster_path: NodePath
@export var damage: int = 1
@export var dash: float = 160

var attack_vfx: Flash_Object
var windup_vfx: Flash_Object
var caster: ShapeCast2D

func _start(m: PlayerMovement, sig = null):
	super._start(m, sig)
	attack_vfx = m.get_node(attack_vfx_path)
	windup_vfx = m.get_node(windupvfx_path)
	caster = m.get_node(caster_path)

var charge: int = 0
func _perform_action():
	#print("attack")
	
	if not move.taking_action and windup_timer == 0 and attack_timer == 0 and cooldown_timer == 0 and PlayerInput.pause_time == 0:
		move.interact_end.emit()
		charge = starting_charge
		if windup <= 0:
			windup_timer = -INF
			print("no windup")
		else:
			windup_timer = windup
			move.rpc("network_charge_sfx", charge)
		move.taking_action = true
		windup_vfx._trigger_event()
		PlayerInput._pause_movement(attack_duration + windup + buffer)
	elif windup_timer > 0:
		charge += 1
		move.rpc("network_charge_sfx", charge)
		#print("charging")

var windup_timer: float = 0
var attack_timer: float = 0
var cooldown_timer: float = 0
var buffer_timer: float = 0
func _update(_delta: float):
	update_timers(_delta)
	if attack_timer > 0:
		try_damage()

func update_timers(delta: float):
	if windup_timer > 0:
		windup_timer -= delta
		if windup_timer <= 0:
			if attack_duration > 0:
				attack_timer = attack_duration + windup_timer
			else:
				attack_timer = -INF
			windup_timer = 0
			attack_visible(true)
			move.velocity.x += dash * sign(move.pivot.scale.x) * sqrt(charge)
			move._delay_gravity(attack_duration / 4)
	
	if attack_timer > 0 or attack_duration == 0:
		attack_timer -= delta
		if attack_timer <= 0:
			if cooldown > 0:
				buffer_timer = buffer + attack_timer
			else:
				cooldown_timer = -INF
			attack_timer = 0
			attack_visible(false)
	
	if buffer_timer > 0:
		buffer_timer -= delta
		if buffer_timer <= 0:
			cooldown_timer = cooldown + buffer_timer
			buffer_timer = 0
			move.taking_action = false
	
	if cooldown_timer > 0:
		cooldown_timer -= delta
		if cooldown_timer <= 0:
			cooldown_timer = 0
			charge = starting_charge

var ignore: Array[Node2D]
func try_damage():
	caster.force_shapecast_update()
	var objects: Array = caster.collision_result
	if not objects or not objects.size():
		return
	
	for o in objects:
		var obj: Node2D = o.get("collider")
		if obj:
			if obj.get_meta("Mortal") and ignore.find(obj) == -1:
				print("attacking")
				var damage_actual: int = obj._take_damage(damage, move.global_position.x)
				if damage_actual or true:
					move.energy._replenish_charge(damage_actual)
				#print("damaging enemy")
				ignore.append(obj)

func attack_visible(value: bool):
	caster.enabled = value
	if value:
		attack_vfx._trigger_event()
	else:
		ignore.clear()
