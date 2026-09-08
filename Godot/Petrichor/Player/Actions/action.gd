@abstract
extends Resource
class_name Action

var move: PlayerMovement

func _start(m: PlayerMovement, sig = null):
	move = m
	if sig and not sig.is_connected(_perform_action):
		sig.connect(_perform_action)

func _update(_delta: float): pass

@abstract func _perform_action()
