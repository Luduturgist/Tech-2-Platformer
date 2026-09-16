extends Action
class_name Brace_Action

@export var slow: float = 0.5
@export var time: float = 1
@export var pound_velocity: int = 20
@export var clamp_x: int = 30
var fx: Brace_Object

const VFX_ID := "Brace"
const SLOW_MOD_ID := "Bracing"

func _start(m: PlayerMovement, sig = null):
	super._start(m, sig)
	fx = move.find_child(VFX_ID, true)
	fx.brace_released.connect(_release_action)

func _perform_action():
	#move.taking_action = true
	if move.taking_action:
		return
	
	move.taking_action = true
	fx.rpc("set_brace", time)
	#move.speed_mods.get_or_add(SLOW_MOD_ID, slow)
	PlayerInput._pause_movement(time)
	if not move.is_on_floor():
		move.velocity.y += pound_velocity
		move.velocity.x = clamp(move.velocity.x, -clamp_x, clamp_x)
		await move.player_land
		_release_action()

func _release_action():
	move.taking_action = false
	move.speed_mods.erase(SLOW_MOD_ID)
