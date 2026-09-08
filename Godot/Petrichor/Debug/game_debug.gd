extends Node

@export var dress_on_start := true
@export var gui: PlayerGUI
@export var camera: Game_Cam
@export var friend: PlayerMovement

func _ready() -> void:
	Game_Scene.active = Game_Scene.new()
	Game_Scene.active.gui = gui
	Game_Scene.active.friend = friend
	
	PlayerInput.moving = true
	if dress_on_start:
		var children = get_children()
		for child in children:
			if child.get_script() == PlayerMovement:
				child.dress()
				camera.follow = child
				Game_Scene.active.local = child
				return
