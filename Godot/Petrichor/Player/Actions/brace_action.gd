extends Action
class_name Brace_Action


@export var slow: float = 0.5
@export var time: float = 1
var fx: Brace_Object

const VFX_ID := "Brace"
const SLOW_ID := "Bracing"

func _start(m: PlayerMovement):
	super._start(m)
	fx = move.find_child(VFX_ID, true)

func _perform_action():
	#move.taking_action = true
	if not move.is_on_floor(): return
	rig_effects(true)
	fx.rpc("set_brace")

func _release_action():
	if not fx.visible: return
	fx.rpc("set_brace", time)
	await fx.brace_released
	rig_effects(false)



func rig_effects(value: bool):
	move.taking_action = value
