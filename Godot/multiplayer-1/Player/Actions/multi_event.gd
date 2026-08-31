extends Action
class_name MultiAction

@export var actions: Array[Action]

func _perform_action():
	for a in actions:
		a._perform_action()
