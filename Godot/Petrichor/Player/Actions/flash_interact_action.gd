extends Action
class_name Flash_Interact_Action

@export var fade_path: NodePath
var fader
var flashing: bool = false

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
	flashing = true
	await fader.fade_ended 
	if flashing:
		move.interact_end.emit()
		flashing = false
	#move.taking_action = false

func _update(_delta: float):
	return
	if flashing and PlayerInput.player_movement.x != 0:
		move.interact_end.emit()
		flashing = false
