extends Node2D
class_name Game

@export var soil: PlayerMovement
@export var river: PlayerMovement
@export var camera: Game_Cam
@export var gui: PlayerGUI

var local: PlayerMovement
var friend: PlayerMovement
const COMBAT_METADATA := "Mortal"
const RIVER_NAME := "Player_River"
const SOIL_NAME := "Player_Soil"

static var active: Game
func _ready() -> void:
	active = self
	if gui: gui.visible = true
	host_setup()

func host_setup():
	if not multiplayer.is_server(): return
	rpc("dress_rig")

static func check_combat(node: Node) -> bool:
	return node.get_meta(Game.COMBAT_METADATA, false)

@rpc("authority", "call_local", "reliable")
func dress_rig():
	river.set_multiplayer_authority(Wrapper.client, true)
	if multiplayer.is_server():
		local = soil
		friend = river
	else:
		local = river
		friend = soil
	
	local.dress()
	camera.follow = local
	
	#camera.global_position = local.global_position
	
	#push_error("A is owned by " + str(playerA.get_multiplayer_authority()))
	#push_error("B is owned by " + str(playerB.get_multiplayer_authority()))
