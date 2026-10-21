extends Area2D
class_name Attack_Lever

@export var dependency: Hold_Interact
@export var event_objects: Array[Event_Object]
@export var oneshot: bool = true
@export var animator: AnimatedSprite2D
@export var light: Node2D
@export var enable_sound: AudioStream
@export var trigger_sound: AudioStream

var activated: bool = false
signal flipped(id: int)

func _ready():
	set_meta("Mortal", true)
	if dependency:
		dependency.activated.connect(_indicate_availability.bind(true))
		dependency.deactivated.connect(_indicate_availability.bind(false))
	else:
		light.visible = true

func _indicate_availability(value: bool):
	if activated and oneshot:
		return
	
	light.visible = value
	if enable_sound:
		$AudioStreamPlayer2D.stream = enable_sound
		$AudioStreamPlayer2D.play()

func _take_damage(_amount: int, _pos: float) -> int:
	if oneshot and activated:
		return 0
	
	
	if dependency.pressed:
		for ob in event_objects:
			ob._trigger_event()
		rpc("flip_lever", multiplayer.get_unique_id())
	return 0

@rpc("call_local", "reliable", "any_peer")
func flip_lever(id: int):
	if oneshot:
		dependency._exhaust()
		set_meta("Mortal", false)
		light.visible = false
	
	if trigger_sound:
		$AudioStreamPlayer2D.stream = trigger_sound
		$AudioStreamPlayer2D.play()
	activated = not activated
	var anim: StringName = &"Turn On"
	if not activated:
		anim = &"Turn Off"
	if animator:
		animator.animation = anim
		animator.play()
	#print("Animation")
	flipped.emit(id)
