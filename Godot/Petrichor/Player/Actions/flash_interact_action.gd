extends Action
class_name Flash_Interact_Action

@export var fade_path: NodePath
var fader

func _start(m: PlayerMovement, sig = null):
	super._start(m, sig)
	await move.get_tree().process_frame
	fader = move.get_node(fade_path)

func _perform_action():
	if move.taking_action or not PlayerInput.moving:
		return
	
	move.interact.emit()
	
	if move.cheering:
		return
	
	fader._trigger_event()
	#move.taking_action = true
	move.special_interact.emit()
	await fader.fade_ended
	#move.taking_action = false
