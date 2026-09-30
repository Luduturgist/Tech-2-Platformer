extends Action
class_name Swing_Action

@export var swing:= 400
@export var ground_repel: Vector2 = Vector2(-175, -150)
@export var air_repel: Vector2 = Vector2(-50, -250)
@export var energy_drain: int = 2
@export var cooldown: float = 0.25
@export var push_back: float = 30
var cast: ShapeCast2D

func _start(m: PlayerMovement, sig = null):
	super._start(m, sig)
	m.player_land.connect(_reset_swing)
	cast = m.push_cast

var can_swing: bool = false
func _perform_action():
	if not can_swing and not move.is_on_floor() or move.taking_action:
		return
	
	var energy: float = 1
	if energy_drain:
		energy = float(move.energy._drain_charge(energy_drain))/ float(energy_drain)
		if energy <= 0: return
	
	if Game_Scene.active.friend.cheering:
		perform_pull(energy)
	else:
		perform_push(energy)
	can_swing = false
	move.taking_action = true

func perform_pull(energy: float):
	#if move.velocity.length() > 200:
		#return
	
	var friend:= Game_Scene.active.friend.position
	var diff = friend - move.position
	var dir = diff.normalized() * swing * energy
	move.velocity += dir
	if dir.x * move.pivot.scale.x < 0: move.pivot.scale.x *= -1
	if move.velocity.length() > swing:
		move.velocity = move.velocity.normalized() * swing * energy
	#velocity.x = clamp(velocity.x + dir.x, -dir.x, dir.x)
	#velocity.y = clamp(velocity.y + dir.y, -dir.y, dir.y)
	while move.velocity.length() > move.move_speed:
		await move.get_tree().process_frame
	move.taking_action = false

func perform_push(energy: float):
	print("???")
	
	cast.push_multiplier = energy / energy_drain
	cast._trigger_event(move.multiplayer.get_unique_id())
	
	#var a: int = await cast.hits_calculated
	
	if move.is_on_floor():
		move.velocity.x += sign(move.pivot.scale.x) * ground_repel.x
		move.velocity.y = ground_repel.y
	else:
		move.velocity.x += sign(move.pivot.scale.x) * air_repel.x
		move.velocity.y = air_repel.y
	
	#if move.is_on_floor():
	#	move.velocity.x += sign(move.pivot.scale.x) * ground_repel.x * energy
	#	move.velocity.y = 
	#else:
	#	move.velocity.y += -down_push * energy
	await move.get_tree().create_timer(cooldown).timeout
	move.taking_action = false

func _reset_swing():
	can_swing = true
