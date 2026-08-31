extends Event
class_name MultiEvent

@export var actions: Array[Event]

func _perform_event():
	for a in actions:
		a._perform_event()
