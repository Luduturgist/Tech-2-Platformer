extends Resource
class_name PlayerEnergy

@export var charge: int = 10
@export var maxCharge: int = 10
@export var pain: int = 0
@export var health: int = 10
@export var maxHealth: int = 10
@export var regen: float = 0
signal depleted
var move: PlayerMovement
var gui: PlayerGUI

func _init(m: PlayerMovement) -> void:
	move = m
	gui = Game.active.gui
	if charge > maxCharge - pain:
		charge = maxCharge - pain
	update_ui()

func _debug():
	charge = maxCharge
	pain = 0
	health = maxHealth
	update_ui()

func _replenish_charge(amount: int) -> int:
	charge += amount
	if charge > maxCharge - pain:
		amount += maxCharge - pain - amount
		charge = maxCharge - pain
	update_ui()
	return amount

func _drain_charge(amount: int) -> int:
	var drain: int = amount
	charge -= amount
	if charge <= 0:
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
	if gui:
		gui.energyBar.value = float(charge) / float(maxCharge) * 100
		gui.pain_bar.value = float(pain) / float(maxCharge) * 100
