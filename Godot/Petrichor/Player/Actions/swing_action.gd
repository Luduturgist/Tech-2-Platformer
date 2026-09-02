extends Action
class_name Swing_Action

@export var swing:= 400
@export var energy_drain: int = 2

func _perform_action():
	var energy: float = 1
	if energy_drain:
		energy = float(move.energy._drain_charge(energy_drain))/ float(energy_drain)
		if not energy: return
	
	move.taking_action = true
	var friend:= Game.active.friend.position
	var diff = friend - move.position
	var dir = diff.normalized() * swing * energy
	move.velocity += dir
	if dir.x * move.pivot.scale.x < 0: move.pivot.scale.x *= -1
	if move.velocity.length() > swing:
		move.velocity = move.velocity.normalized() * swing * energy
	#velocity.x = clamp(velocity.x + dir.x, -dir.x, dir.x)
	#velocity.y = clamp(velocity.y + dir.y, -dir.y, dir.y)
	print("swingin " + str(diff))
	while move.velocity.length() > move.move_speed:
		await move.get_tree().process_frame
	move.taking_action = false
