extends Action
class_name Event_Action

@export var event_path: NodePath

func _perform_action():
	var e = move.get_node(event_path)
	if e is Event_Object:
		e._trigger_event()
