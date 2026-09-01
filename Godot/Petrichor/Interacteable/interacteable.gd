extends Node2D
class_name Interacteable

@export var light: Node
@export var player_area: Area2D

@export var event_objects: Array[Event_Object]
@export var single_use := true

var local := true

func _ready() -> void:
	player_area.body_entered.connect(try_player.bind(1))
	player_area.body_exited.connect(try_player.bind(-1))

func try_player(body: Node2D, i: int):
	if not exhausted and body is PlayerMovement and body.local:
		rpc("flip_light", i)
		if i > 0:
			body.interact.connect(interact)
		else:
			body.interact.disconnect(interact)

var exhausted := false
func interact():
	if exhausted: return
	
	for e in event_objects:
		e._trigger_event()
	if single_use:
		rpc("flip_light", -10)

var contacts: int = 0
@rpc("any_peer", "call_local", "reliable")
func flip_light(i: int):
	if i == -10:
		contacts = 0
		light.visible = false
		exhausted = true
	contacts += i
	light.visible = contacts > 0
