extends Node2D
class_name Game

@export var playerA: Movement
@export var playerB: Movement

var local: Movement
var friend: Movement

static var active: Game
func _ready() -> void:
	active = self
	start()

func start():
	if not multiplayer.is_server(): return
	
	rpc("dress_rig")

@rpc("authority", "call_local")
func dress_rig():
	playerB.set_multiplayer_authority(Wrapper.client, true)
	if multiplayer.is_server():
		local = playerA
		friend = playerB
	else:
		local = playerB
		friend = playerA
	
	local.dress()
	
	#push_error("A is owned by " + str(playerA.get_multiplayer_authority()))
	#push_error("B is owned by " + str(playerB.get_multiplayer_authority()))
