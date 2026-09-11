@abstract
extends Resource
class_name Action

var move: PlayerMovement

func _start(m: PlayerMovement, sig = null):
	move = m
	if sig and sig:
		sig.connect(_perform_action)
		move.tree_exited.connect(func(): sig.disconnect(_perform_action))

func _update(_delta: float): pass

@abstract func _perform_action()
