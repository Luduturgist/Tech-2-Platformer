extends Event_Object
class_name Door_Object

@export var lock_open := false
@export var door_block: Node2D

func _ready() -> void:
	super._ready()
	Wrapper.scene_ready.connect(_sync_door)

func _trigger_event(_toggle: int = 0):
	var value := not door_block.visible
	if value and lock_open: return
	rpc("open_door", value)

func _sync_door():
	if multiplayer.is_server():
		rpc("open_door", door_block.visible)

@rpc("any_peer", "call_local", "reliable")
func open_door(value: int):
	door_block.visible = value
	door_block.find_child("CollisionShape2D").disabled = not value
