extends Action
class_name Swing_Action

@export var swing:= 500

func _perform_event():
	var friend:= Game.active.friend.position
	var diff = friend - move.position
	var dir = diff.normalized() * swing
	move.velocity += dir
	if move.velocity.length() > swing:
		move.velocity = move.velocity.normalized() * swing
	#velocity.x = clamp(velocity.x + dir.x, -dir.x, dir.x)
	#velocity.y = clamp(velocity.y + dir.y, -dir.y, dir.y)
	print("swingin " + str(diff))
