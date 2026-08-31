extends Node2D
class_name Interacteable

@export var light: Node
@export var player_area: Area2D

@export var event_objects: Array[Event_Object]

var local := true

func _ready() -> void:
	player_area.body_entered.connect(try_player.bind(1))
	player_area.body_exited.connect(try_player.bind(-1))

func try_player(body: Node2D, i: int):
	if body is PlayerMovement and body.local:
		rpc("flip_light", i)
		if i > 0:
			body.interact.connect(interact)
		else:
			body.interact.disconnect(interact)

func interact():
	for e in event_objects:
		e._trigger_event()

var contacts: int = 0
@rpc("any_peer", "call_local")
func flip_light(i: int):
	contacts += i
	light.visible = contacts
