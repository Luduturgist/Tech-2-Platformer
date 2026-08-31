extends Node2D

@export var light: Node
@export var player_area: Area2D

func _ready() -> void:
	player_area.body_entered.connect(try_player.bind(1))
	player_area.body_exited.connect(try_player.bind(-1))

func try_player(body: Node2D, i: int):
	if body is PlayerMovement and body.local:
		rpc("flip_light", i)

var contacts: int = 0
@rpc("any_peer", "call_local")
func flip_light(i: int):
	contacts += i
	light.visible = contacts
