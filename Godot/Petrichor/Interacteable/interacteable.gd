extends Node2D
class_name Interacteable

@export var highlights: Array[Event_Object]
@export var player_area: Area2D

@export var event_objects: Array[Event_Object]
@export var single_use := true
@export var attackable: bool = false

signal interacted(id: float)

var local := true

func _take_damage(amount: int):
	interact()

func _ready() -> void:
	if attackable:
		set_meta("Mortal", true)
	else:
		player_area.body_entered.connect(try_player.bind(1))
		player_area.body_exited.connect(try_player.bind(-1))

func try_player(body: Node2D, i: int):
	if not multiplayer.multiplayer_peer:
		return
	if not exhausted and body is PlayerMovement and body.local:
		rpc("flip_light", i, )
		if i > 0:
			body.special_interact.connect(interact)
		else:
			body.special_interact.disconnect(interact)

var exhausted := false
func interact():
	if exhausted: return
	
	interacted.emit()
	
	if event_objects.size():
		for e in event_objects:
			e._trigger_event()
	if single_use:
		rpc("flip_light", -10,)

var contacts: int = 0
@rpc("any_peer", "call_local", "reliable")
func flip_light(i: int):
	if i == -10:
		exhausted = true
		contacts = 0
		toggle_highlights(false)
		return
	contacts += i
	toggle_highlights(contacts > 0)

func toggle_highlights(toggle: bool):
		if not highlights.size(): return
		
		var value: int = 1
		if not toggle: value = -1
		
		for h in highlights:
			h._trigger_event(value)
