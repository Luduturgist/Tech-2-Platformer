@abstract
extends Event
class_name Action

var move: PlayerMovement

func _start(m: PlayerMovement):
	move = m
