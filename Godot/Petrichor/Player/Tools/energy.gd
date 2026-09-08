extends Resource
class_name PlayerEnergy

@export var charge: int = 10
@export var maxCharge: int = 10
@export var pain: int = 0
@export var health: int = 10
@export var maxHealth: int = 10
@export var drain_interval: float = 4
@export var movement_multiplier = 2
signal depleted
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
	while _drain_timer <= 0:
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
	if charge <= 0:
		if overdraw:
			_inflict_pain(-charge)
		else:
			drain += charge
		charge = 0
		depleted.emit()
	update_ui()
	return drain

func _take_damage(amount: int, hurt: int = -99):
	health -= amount
	if health <= 0:
		health = 0
		move.player_die()
	elif health > maxHealth:
		health = maxHealth
	if hurt == -99:
		_inflict_pain(amount)
	else:
		_inflict_pain(hurt)
	update_ui()

func _heal_damage(amount: int):
	health += amount
	if health > maxHealth:
		health = maxHealth
	update_ui()

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
