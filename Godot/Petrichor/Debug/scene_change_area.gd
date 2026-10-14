extends Area_Detector
class_name Sceneload_Detector

@export var scene: String
@export var disconnect: bool = false

func _ready():
	super._ready()
	if is_multiplayer_authority():
		target_found.connect(change_scene)

func change_scene():
	if scene:
		if disconnect:
			Wrapper._end_session(scene)
		else:
			Wrapper._load_scene(scene)
	else:
		push_error("Bad Scene Name")
