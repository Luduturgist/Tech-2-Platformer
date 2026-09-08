extends Action
class_name Flash_Interact_Action

@export var fade_path: NodePath

func _start(m: PlayerMovement, sig = null):
	super._start(m, sig)

func _perform_action():
	if move.taking_action or not PlayerInput.moving:
		return
	
	move.interact.emit()
	move.get_node(fade_path)._trigger_event()
	move.taking_action = true
	print("asdgfszhwerusad")
	await move.get_node(fade_path).fade_ended
	print("asdgfsad")
	move.taking_action = false
