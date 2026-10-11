extends Area2D
class_name Attack_Lever

@export var dependency: Hold_Interact
@export var event_object: Event_Object
@export var oneshot: bool = true
@export var animator: AnimatedSprite2D

var activated: bool = false

func _ready():
	set_meta("Mortal", true)

func _take_damage(_amount: int, _pos: float) -> int:
	if oneshot and activated:
		return 0
	
	
	if dependency.pressed:
		event_object._trigger_event()
		rpc("flip_lever")
	return 0

@rpc("call_local", "reliable", "any_peer")
func flip_lever():
	if oneshot:
		dependency._exhaust()
		set_meta("Mortal", false)
	
	$AudioStreamPlayer2D.play()
	activated = not activated
	var anim: StringName = &"Turn On"
	if not activated:
		anim = &"Turn Off"
	animator.animation = anim
	animator.play()
	print("Animation")
