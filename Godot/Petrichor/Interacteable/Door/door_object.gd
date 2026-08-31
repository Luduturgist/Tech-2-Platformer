extends Event_Object
class_name Door_Object

@export var lock_open := true
@export var door_block: StaticBody2D

func _trigger_event():
	var value := not door_block.visible
	if value and lock_open: return
	rpc("open_door", value)

@rpc("any_peer", "call_local")
func open_door(value: int):
	door_block.visible = value
	door_block.find_child("CollisionShape2D").disabled = not value
