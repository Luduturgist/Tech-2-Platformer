extends Node

var client_id: int = 0
var friend_id: int = 0
@onready var peer = ENetMultiplayerPeer.new()
@export var disconnect_screen: CanvasLayer
@export var ip_reference: Label

var localIP: String
var local_type: Golem = Golem.UNASSIGNED
enum Golem {UNASSIGNED, GOLEM_SOIL, GOLEM_RIVER}

signal scene_ready
var scene_synchronized: bool = false
signal begin_desync
signal connection_failed
const fallback_scene: String = "res://UI/Root Menus/Main Menu/Main Menu.tscn"

func _ready() -> void:
	_refresh_ip()
	multiplayer.connected_to_server.connect(_debug_server)
	multiplayer.peer_connected.connect(_register_client)
	multiplayer.peer_disconnected.connect(_interrupt_session)
	$"Game Disconnected/VBoxContainer/HBoxContainer/Main Menu".pressed.connect(_end_session)

func _debug_server():
	pass
	#print("hi server")

func _refresh_ip() -> String:
	for ip in IP.get_local_addresses():
		if ip.contains(".") and (ip.begins_with("10.") or ip.begins_with("192.168.")):
			localIP = ip
			return ip
	return ""

func _host():
	peer.create_server(1027, 1)
	multiplayer.multiplayer_peer = peer
	if local_type == Golem.UNASSIGNED:
		local_type = Golem.GOLEM_SOIL
		if PlayerInput.input_override <= 0:
			PlayerInput.input_override = PlayerInput.input_type.INPUT_KEYBOARD

func _join(ip: String = localIP):
	if ip == localIP:
		AudioHandler._mute()
		PlayerInput.input_override = PlayerInput.input_type.INPUT_CONTROLLER
	
	print(ip, ", " , localIP)
	
	peer.create_client(ip, 1027)
	multiplayer.multiplayer_peer = peer
	print("joining")

func _register_client(id: int):
	#print("hello there")
	
	disconnect_screen.visible = false
	if id != 1:
		client_id = id
	else:
		client_id = multiplayer.get_unique_id()
	
	if multiplayer.is_server():
		friend_id = id
		if peer.get_peer(id).get_remote_address() == localIP:
			PlayerInput.input_override = PlayerInput.input_type.INPUT_KEYBOARD
	else:
		friend_id = 1
	
	if multiplayer.is_server():
		if local_type == Golem.GOLEM_SOIL:
			rpc("assign_golem", Golem.GOLEM_RIVER as int)
		elif local_type == Golem.GOLEM_RIVER:
			rpc("assign_golem", Golem.GOLEM_SOIL as int)
		scene_loaded()

func _interrupt_session(id: int = -1):
	if id != friend_id:
		return
	
	client_id = 0
	friend_id = 0
	peer.close()
	PlayerInput.moving = false
	await get_tree().process_frame
	scene_synchronized = false
	scene_tally = 0
	#Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	
	if get_tree().current_scene is Game_Scene:
		_buffer_disconnect()
	else:
		_end_session()

func _buffer_disconnect():
	if local_type == Golem.GOLEM_RIVER: print("switching to host")
	_host()
	disconnect_screen.visible = true
	_refresh_ip()
	ip_reference.text = str(localIP)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _end_session(error: bool = false):
	scene_synchronized = false
	client_id = 0
	friend_id = 0
	peer.close()
	local_type = Golem.UNASSIGNED
	scene_tally = 0
	
	disconnect_screen.visible = false
	if get_tree().current_scene.scene_file_path != fallback_scene or not error:
		get_tree().change_scene_to_file(fallback_scene)
		await get_tree().scene_changed
	if error: connection_failed.emit()

func scene_loaded():
	if client_id != 0 and local_type != Golem.UNASSIGNED:
		rpc("scene_checkin", get_tree().current_scene.scene_file_path)

var scene_tally: int = 0
@rpc("call_local", "any_peer", "reliable")
func scene_checkin(scene: String, id: int = 0):
	#print("checking in")
	await get_tree().process_frame
	await get_tree().process_frame
	if scene != get_tree().current_scene.scene_file_path:
		scene_synchronized = false
		if multiplayer.is_server():
			rpc("scene_checkin", get_tree().current_scene.scene_file_path, 1)
		elif id == 1:
			get_tree().change_scene_to_file(scene)
			await get_tree().process_frame
			scene_checkin(scene, 1)
		return
	
	scene_tally += 1
	if scene_tally >= 2:
		#print("everyone in")
		scene_tally = 0
		scene_ready.emit()
		scene_synchronized = true
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _load_scene(scene: String):
	rpc("multiplayer_scene", scene)

@rpc("call_local", "any_peer", "reliable")
func multiplayer_scene(scene: String):
	await TransitionHandler._close_scene()
	print("waiting over")
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	begin_desync.emit()
	scene_synchronized = false
	get_tree().call_deferred("change_scene_to_file", scene)
	await get_tree().scene_changed
	rpc("scene_checkin", scene, multiplayer.get_unique_id())

@rpc("call_remote", "authority", "reliable")
func assign_golem(i: int):
	local_type = i as Golem
	#print("Golem " + str(i) + " loaded")
	scene_loaded()
