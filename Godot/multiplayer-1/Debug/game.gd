extends Node2D

@export var playerA: Movement
@export var playerB: Movement

func _ready() -> void:
	start()

func start():
	if not multiplayer.is_server(): return
	
	rpc("dress_rig")

@rpc("authority", "call_local")
func dress_rig():
	playerB.set_multiplayer_authority(Wrapper.client, true)
	if multiplayer.is_server():
		playerA.dress()
	else:
		playerB.dress()
