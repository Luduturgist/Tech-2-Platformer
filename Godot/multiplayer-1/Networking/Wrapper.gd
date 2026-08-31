extends Node
class_name NetworkingWrapper

var client: int = 0
@onready var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()

var localIP: String

func _ready() -> void:
	peer.peer_connected.connect(_register_client)
	for ip in IP.get_local_addresses():
		if ip.contains(".") and (ip.begins_with("10.") or ip.begins_with("192.168.")):
			localIP = ip
			return

func _host():
	peer.create_server(1027, 2)
	multiplayer.multiplayer_peer = peer

func _join(ip: String = localIP):
	peer.create_client(ip, 1027)
	multiplayer.multiplayer_peer = peer

func _register_client(id: int):
	if id != 1: client = id
	else: client = multiplayer.get_unique_id()

func _end_session():
	peer.close()
	get_tree().change_scene_to_file("res://UI/Main Menu.tscn")

func _load_scene(scene: String):
	rpc("multiplayer_scene", scene)

@rpc("call_local", "any_peer")
func multiplayer_scene(scene: String):
	get_tree().call_deferred("change_scene_to_file", scene)
