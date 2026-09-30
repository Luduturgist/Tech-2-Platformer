extends Resource
class_name PlayerEnergy

@export var charge: int = 20
@export var maxCharge: int = 20
@export var pain: int = 0
@export var drain_interval: float = 8
@export var movement_multiplier = 2
var move: PlayerMovement

func _start(m: PlayerMovement):
	move = m
	if charge > maxCharge - pain:
		charge = maxCharge - pain
	_drain_timer = drain_interval
	update_ui()

var _drain_timer: float
func _update(delta: float):
	if move.velocity.x and PlayerInput.moving and PlayerInput.player_movement.x:
		delta *= movement_multiplier
	_drain_timer -= delta
	while drain_interval > 0 and _drain_timer <= 0:
		_drain_timer += drain_interval
		_drain_charge(1, true)

func _debug():
	_replenish_charge(maxCharge)
	update_ui()

func _replenish_charge(amount: int) -> int:
	charge += amount
	if charge > maxCharge - pain:
		amount += maxCharge - pain - amount
		charge = maxCharge - pain
	update_ui()
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
	update_ui()
	return drain

func _inflict_pain(amount: int):
	pain += amount
	if pain < 0: pain = 0
	if pain >= maxCharge:
		move.player_die()
	elif charge > maxCharge - pain:
		charge = maxCharge - pain
	update_ui()

func _relieve_pain(amount: int):
	pain -= amount
	if pain < 0:
		pain = 0
	update_ui()

func on_deplete():
	Wrapper._end_session()

func update_ui():
	if Game_Scene.active.gui:
		Game_Scene.active.gui.energyBar.value = float(charge) / float(maxCharge) * 100
		Game_Scene.active.gui.pain_bar.value = float(pain) / float(maxCharge) * 100
