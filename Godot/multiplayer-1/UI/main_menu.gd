extends Node2D


func _ready() -> void:
	$"Network Buttons/Host".pressed.connect(host_button)
	$"Network Buttons/Join".pressed.connect(join_button)
	$"Host Waiting/Disconnect".pressed.connect(back_button)
	$"Client Waiting/Disconnect".pressed.connect(back_button)

func host_button():
	Wrapper._host()
	switch(true)

func join_button():
	Wrapper._join()
	switch()

func back_button():
	Wrapper._disconnect()

func switch(host: bool = false):
	$"Network Buttons".visible = false
	if host: $"Host Waiting".visible = true
	else: $"Client Waiting".visible = true
