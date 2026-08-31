extends Node2D

@export var scene_to_load: String

func _ready() -> void:
	$"Network Buttons/Host".pressed.connect(host_button)
	$"Network Buttons/Join".pressed.connect(join_button)
	$"Host Waiting/Disconnect".pressed.connect(back_button)
	$"Client Waiting/Disconnect".pressed.connect(back_button)
	Wrapper.peer.peer_connected.connect(player_connected)
	
	$"Network Buttons/Local IP".text = Wrapper.localIP
	$"Host Waiting/Local IP".text = Wrapper.localIP
	$"Network Buttons/Join IP".placeholder_text = Wrapper.localIP

func host_button():
	Wrapper._host()
	switch(true)

func join_button():
	Wrapper._join($"Network Buttons/Join IP".text)
	switch()

func back_button():
	Wrapper._disconnect()

func player_connected(id: int):
	print("Player " + str(id) + " joined!")
	get_tree().change_scene_to_file(scene_to_load)

func switch(host: bool = false):
	$"Network Buttons".visible = false
	if host: $"Host Waiting".visible = true
	else: $"Client Waiting".visible = true
