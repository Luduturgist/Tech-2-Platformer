extends Resource
class_name Energy

@export var value: float = 10
@export var maxValue: float = 10
@export var regen: float = 1
signal depleted
var move: PlayerMovement

func _init(m: PlayerMovement) -> void:
	move = m
	update_ui()

func _update(delta: float):
	_charge(regen * delta)

func _charge(amount: float):
	value += amount
	if value > maxValue:
		value = maxValue
	update_ui()

func _drain(amount: float):
	value -= amount
	if value < 0:
		value = 0
		depleted.emit()
	update_ui()

func on_deplete():
	Wrapper._end_session()

func update_ui():
	Game.active.gui.energyBar.value = value / maxValue * 100
