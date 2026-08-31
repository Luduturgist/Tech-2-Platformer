extends CanvasLayer

@export var buttons: Array[Button]
@export var scenes: Array[String]
@export var flashes: Array[Flash_Object]
@export var auto_select: int = -1

func _ready() -> void:
	for i in buttons.size():
		buttons[i].pressed.connect(press_button.bind(i))
	if auto_select >= 0 and multiplayer.is_server():
		press_button(auto_select)


func press_button(i: int):
	if multiplayer.is_server(): Wrapper._load_scene(scenes[i])
	else:
		flashes[i].rpc("flash")
