@abstract
extends Node
class_name Event_Object

var obj

@abstract func _trigger_event()

func _ready() -> void:
	var s = self
	if s is Control:
		obj = s
	elif s is Node2D:
		obj = s
