extends Node
class_name NetworkingWrapper

var client: int
@onready var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()

func _ready() -> void:
	peer.peer_connected.connect(_register_client)

func _host():
	peer.create_server(1027, 2)
	multiplayer.multiplayer_peer = peer

func _join():
	peer.create_client("127.0.0.1", 1027)
	multiplayer.multiplayer_peer = peer

func _register_client(id: int):
	if id != 1: client = id
	else: client = multiplayer.get_unique_id()

func _disconnect():
	peer.close()
	get_tree().change_scene_to_file("res://UI/Main Menu.tscn")
