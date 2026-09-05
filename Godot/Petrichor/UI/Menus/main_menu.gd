extends Node2D

@export var scene_to_load: String
@export var host_button: Button
@export var join_button: Button
@export var disconnect_1: Button
@export var disconnect_2: Button
@export var ip_texts: Array[Control]
@export var join_ip: LineEdit

func _ready() -> void:
	host_button.pressed.connect(host_pressed)
	join_button.pressed.connect(join_pressed.bind(""))
	disconnect_1.pressed.connect(back_button)
	disconnect_2.pressed.connect(back_button)
	Wrapper.peer.peer_connected.connect(player_connected)
	join_ip.text_submitted.connect(join_pressed)
	
	for i in ip_texts:
		i.text = Wrapper.localIP
	join_ip.placeholder_text = Wrapper.localIP
	
func host_pressed():
	Wrapper._host()
	switch(true)

func join_pressed(_s: String):
	Wrapper._join(join_ip.text)
	switch()

func back_button():
	Wrapper._end_session()

func player_connected(id: int):
	print("Player " + str(id) + " joined!")
	get_tree().change_scene_to_file(scene_to_load)

func switch(host: bool = false):
	$"Network Buttons".visible = false
	if host: $"Host Waiting".visible = true
	else: $"Client Waiting".visible = true
