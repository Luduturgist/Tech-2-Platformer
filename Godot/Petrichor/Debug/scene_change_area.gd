extends Area_Detector
class_name Sceneload_Detector

@export var scene: String

func _ready():
	super._ready()
	if is_multiplayer_authority():
		target_found.connect(change_scene)

func change_scene():
	if scene:
		Wrapper._load_scene(scene)
