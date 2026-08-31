@abstract
extends Resource
class_name Action

var move: PlayerMovement

func _start(m: PlayerMovement):
	move = m

func _update(_delta: float): pass

@abstract func _perform_action()
