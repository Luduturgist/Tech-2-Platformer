extends Node2D

@export var scene_to_load: String
@export var host_button: Button
@export var join_button: Button
@export var disconnect_1: Button
@export var disconnect_2: Button
@export var ip_texts: Array[Control]
@export var join_ip: LineEdit
@export var failure_message: Label
@export var join_wait_ip: Label

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	host_button.pressed.connect(host_pressed)
	join_button.pressed.connect(join_pressed)
	disconnect_1.pressed.connect(back_button)
	disconnect_2.pressed.connect(back_button)
	Wrapper.scene_ready.connect(player_connected)
	join_ip.text_submitted.connect(join_pressed)
	Wrapper.connection_failed.connect(express_failure)
	PlayerInput.moving = false
	
	for i in ip_texts:
		i.text = Wrapper.localIP
	join_ip.placeholder_text = Wrapper.localIP
	
func host_pressed():
	Wrapper._host()
	switch(true)

static var last_try: String
func express_failure():
	failure_message.visible = true
	if last_try:
		join_ip.text = last_try

func join_pressed(join: String = ":("):
	last_try = join_ip.text
	if join == ":(":
		join = join_ip.text
	Wrapper._join(join)
	join_wait_ip.text = join
	switch()

func back_button():
	Wrapper._end_session()

func player_connected():
	if multiplayer and multiplayer.is_server():
		Wrapper._load_scene(scene_to_load)

func switch(host: bool = false):
	$"Network Buttons".visible = false
	if host: $"Host Waiting".visible = true
	else: $"Client Waiting".visible = true
