extends Node
class_name NetworkingWrapper


@onready var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()


func _host():
	peer.create_server(1027)
	multiplayer.multiplayer_peer = peer

func _join():
	peer.create_client("127.0.0.1", 1027)
	multiplayer.multiplayer_peer = peer

func _disconnect():
	peer.close()
	get_tree().change_scene_to_file("res://UI/Main Menu.tscn")
