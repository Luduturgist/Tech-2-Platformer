extends Resource
class_name PlayerEnergy

var charge

@export var maxCharge: int = 10
@export var pain: int = 0
@export var drain_interval: float = 2

var move: PlayerMovement
signal charge_depleted
signal passive_drain_update(bool)
signal drained(amount: int)
signal update_ui(energy: int, pain: int)

func _start(m: PlayerMovement):
	move = m
	charge = maxCharge
	if charge > maxCharge - pain:
		charge = maxCharge - pain
	_drain_timer = drain_interval
	update_ui.emit(charge, pain)

var _drain_timer: float
var draining: bool
func _update(delta: float):
	var climbing: bool = PlayerInput.player_movement.y != 0 and not move.using_gravity
	
	if PlayerInput.player_movement.x != 0 or move.attack._is_attacking() or climbing:
		if not draining:
			draining = true
			passive_drain_update.emit(true)
		_drain_timer -= delta
	elif draining:
		draining = false
		passive_drain_update.emit(false)
	
	while drain_interval > 0 and _drain_timer <= 0:
		_drain_timer += drain_interval
		_drain_charge(1, true)

func _debug():
	_replenish_charge(maxCharge)
	update_ui.emit(charge, pain)

func _replenish_charge(amount: int, overfill: bool = false) -> int:
	charge += amount
	if overfill:
		if maxCharge - pain > charge:
			pain = maxCharge - charge
	
	elif charge > maxCharge - pain and not overfill:
		amount += maxCharge - pain - amount
		charge = maxCharge - pain
	update_ui.emit(charge, pain)
	move.rpc("network_damage", true)
	return amount

func _drain_charge(amount: int, overdraw: bool = false) -> int:
	var drain: int = amount
	charge -= amount
	if charge < 0:
		if overdraw:
			move._take_damage(-charge)
		else:
			drain += charge
		charge = 0
		charge_depleted.emit()
	update_ui.emit(charge, pain)
	drained.emit(amount)
	return drain

func _inflict_pain(amount: int):
	pain += amount
	if pain < 0: pain = 0
	if pain >= maxCharge:
		move.player_die()
	elif charge > maxCharge - pain:
		charge = maxCharge - pain
	update_ui.emit(charge, pain)

func _relieve_pain(amount: int):
	pain -= amount
	if pain < 0:
		pain = 0
	update_ui.emit(charge, pain)

func on_deplete():
	Wrapper._end_session()
