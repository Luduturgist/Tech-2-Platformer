extends Action
class_name BasicAttack_Action

@export var windup: float = 0.7
@export var attack_duration: float = 0.2
@export var cooldown: float = 0.2
@export var vfx_path: NodePath
@export var caster_path: NodePath
@export var damage: int = 1

var vfx: Flash_Object
var caster: ShapeCast2D

func _start(m: PlayerMovement, sig = null):
	super._start(m, sig)
	vfx = m.get_node(vfx_path)
	caster = m.get_node(caster_path)

func _perform_action():
	#print("attack")
	
	if not move.taking_action and windup_timer == 0 and attack_timer == 0 and cooldown_timer == 0:
		if windup <= 0:
			windup_timer = -INF
			print("no windup")
		else:
			windup_timer = windup
		move.taking_action = true

var windup_timer: float = 0
var attack_timer: float = 0
var cooldown_timer: float = 0
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
			set_visible(true)
	
	if attack_timer > 0 or attack_duration == 0:
		attack_timer -= delta
		if attack_timer <= 0:
			if cooldown > 0:
				cooldown_timer = cooldown + attack_timer
			else:
				cooldown_timer = -INF
			attack_timer = 0
			set_visible(false)
	
	if cooldown_timer > 0:
		cooldown_timer -= delta
		if cooldown_timer <= 0:
			cooldown_timer = 0

var ignore: Array[Node2D]
func try_damage():
	var objects: Array = caster.collision_result
	if not objects or not objects.size():
		return
	
	for o in objects:
		var obj: Node2D = o.get("collider")
		if obj:
			if obj.get_meta("Mortal") and obj is Enemy and ignore.find(obj) == -1:
				obj._take_damage(damage)
				print("damaging enemy")
				ignore.append(obj)

func set_visible(value: bool):
	caster.enabled = value
	if value:
		vfx._trigger_event()
		PlayerInput._pause_movement(attack_timer)
	else:
		ignore.clear()
		move.taking_action = false
