@abstract
extends Resource
class_name Event

func _start(m: PlayerMovement): pass

func _update(_delta: float): pass

@abstract func _perform_event()
