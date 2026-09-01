extends Action

@export var slow: float = 1

const VFX_ID := "Brace"
const SLOW_ID := "Bracing"

var fx: Node2D
func _start(m: PlayerMovement):
	fx = move.find_child(VFX_ID)

var bracing := false
func _perform_action():
	if bracing:
		move.speed_mods.set(SLOW_ID, slow)
		fx.visible = true
	else:
		move.speed_mods.erase(SLOW_ID)
	bracing = not bracing
