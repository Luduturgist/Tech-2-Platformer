extends Node2D
class_name Game_Scene

@export var soil: PlayerMovement
@export var river: PlayerMovement
@export var camera: Cam_Director
@export var gui: PlayerGUI

var local: PlayerMovement
var friend: PlayerMovement
const COMBAT_METADATA := "Mortal"
const RIVER_NAME := "Player_River"
const SOIL_NAME := "Player_Soil"
const PAUSE_PATH := "res://UI/Root Menus/Pause Menu/Pause.tscn"

static var active: Game_Scene
var pause: Pause_Menu
var game_started: bool = false


func _ready() -> void:
	active = self
	Wrapper.scene_ready.connect(host_setup)
	pause = load(PAUSE_PATH).instantiate()
	call_deferred("add_child", pause)

func _exit_tree():
	pause.queue_free()
	active = null

func host_setup():
	if not multiplayer.is_server(): return
	rpc("dress_rig", soil.position, river.position)

func start_game():
	PlayerInput.moving = true
	if gui: gui.visible = true
	game_started = true
	TransitionHandler._open_scene()

static func check_combat(node: Node) -> bool:
	return node.get_meta(Game_Scene.COMBAT_METADATA, false)

var rigs_loaded: int = 0
@rpc("authority", "call_local", "reliable")
func dress_rig(soil_pos: Vector2, river_pos: Vector2):
	if Wrapper.local_type == Wrapper.Golem.GOLEM_SOIL:
		local = soil
		friend = river
	elif Wrapper.local_type == Wrapper.Golem.GOLEM_RIVER:
		local = river
		friend = soil
	else:
		push_error("Unassigned golem type")
	if not local.local:
		local.dress()
		camera.follow = local.cam_offset
		camera._activate_camera()

	
	local.set_multiplayer_authority(multiplayer.get_unique_id(), true)
	friend.set_multiplayer_authority(Wrapper.friend_id, true)
	print("id " + str(multiplayer.get_unique_id()) +  " local " + str(multiplayer.get_unique_id()) + " friend " + str(Wrapper.friend_id))
	if not multiplayer.is_server():
		if Wrapper.local_type == Wrapper.Golem.GOLEM_SOIL:
			soil.position = soil_pos
		else:
			river.position = river_pos
	
	rpc("_rig_checkin")

@rpc("any_peer", "call_local", "reliable")
func _rig_checkin():
	rigs_loaded += 1
	
	if rigs_loaded == 2:
		rigs_loaded = 0
		start_game()
	
	#camera.global_position = local.global_position
	
	#push_error("A is owned by " + str(playerA.get_multiplayer_authority()))
	#push_error("B is owned by " + str(playerB.get_multiplayer_authority()))
