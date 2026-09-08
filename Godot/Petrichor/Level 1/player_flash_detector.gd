extends Area2D

@export var events: Array[Event_Object]
@export var oneshot: bool = true

var monitoring_player: bool = false
var triggered: bool = false

func _ready() -> void:
	body_entered.connect(_try_find_player)
	body_exited.connect(_try_lose_player)

func _try_find_player(body: Node2D):
	if body == Game_Scene.active.local and not monitoring_player:
		body.player_flash.connect(_detect_flash)
		monitoring_player = true

func _try_lose_player(body: Node2D):
	if body == Game_Scene.active.local and monitoring_player:
		body.player_flash.disconnect(_detect_flash)
		monitoring_player = false

func _detect_flash():
	if not oneshot or not triggered:
		rpc("_player_flash_detected")

@rpc("any_peer", "reliable", "call_local")
func _player_flash_detected():
	if triggered:
		return
	triggered = true
	for e in events:
		e._trigger_event()
