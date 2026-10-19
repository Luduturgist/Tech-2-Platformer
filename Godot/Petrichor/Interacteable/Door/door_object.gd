extends Event_Object
class_name Door_Object

@export var lock_open := false
@export var door_block: Node2D
@export var start_open: bool = false
@export var player: AudioStreamPlayer2D
@export var door_open_sfx: AudioStream
@export var door_close_sfx: AudioStream

@export var animator: AnimatedSprite2D

func _ready() -> void:
	super._ready()
	open_door(not start_open)
	Wrapper.scene_ready.connect(_sync_door)

func _trigger_event(_toggle: int = 0):
	var value := not door_block.visible
	if value and lock_open: return
	rpc("open_door", value)

func _sync_door():
	if multiplayer.is_server():
		rpc("open_door", door_block.visible)

@rpc("any_peer", "call_local", "reliable")
func open_door(value: int):
	door_block.visible = value
	
	if value and door_open_sfx:
		player.stream = door_open_sfx
		player.play()
	elif not value and door_close_sfx:
		player.stream = door_close_sfx
		player.play()
	
	if animator:
		var anim: StringName = &"Open"
		if value:
			anim = &"Close"

		animator.animation = anim
		animator.play()
	
	await get_tree().process_frame
	
	door_block.find_child("CollisionShape2D").disabled = not value
