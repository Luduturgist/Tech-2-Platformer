extends Event_Object
class_name Event_Accumulator

@export var event_objects: Array [Event_Object]
@export var threshold: int = 1

var accumulation: int
func _trigger_event(_value: int = 0):
	if not is_multiplayer_authority():
		return
	
	accumulation += 1
	if accumulation == threshold:
		for event in event_objects:
			event._trigger_event()
