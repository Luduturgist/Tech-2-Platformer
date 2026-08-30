extends CharacterBody2D
class_name Movement

@export var speed: float = 100
@export var accel: float = 800
@export var jump: float = 300
@export var health: int = 3
@export var fallSpeed: int = 1200
@export var swing:= 500
@export var pivot: Node2D
var sp: float = 0
signal cheering

func dress() -> void:
	sp = speed
	collision_layer = 1
	collision_mask = 1
	visibility_layer = 1
	z_index += 1

func _take_damage(amount: int = 1):
	if sp <= 0: return
	print("pain detected from " + str(multiplayer.get_unique_id()))
	health -= amount
	rpc("damage_feedback")
	if health <= 0:
		Wrapper._load_scene("res://Debug/debug_spikes.tscn")

func coop_swing():
	var friend:= Game.active.friend.position
	var diff = friend - position
	var dir = diff.normalized() * swing
	velocity += dir
	if velocity.length() > swing:
		velocity = velocity.normalized() * swing
	#velocity.x = clamp(velocity.x + dir.x, -dir.x, dir.x)
	#velocity.y = clamp(velocity.y + dir.y, -dir.y, dir.y)
	print("swingin " + str(diff))

func _physics_process(delta: float) -> void:
	if cheer_timer > 0:
		cheer_timer -= delta
		if cheer_timer <= 0:
			if $CollisionShape2D/Cheer.visible:
				$CollisionShape2D/Cheer.visible = false
				cheer_timer = 0
			else:
				$CollisionShape2D/Cheer.visible = true
				cheer_timer = 0.5
	
	if pain_timer > 0:
		pain_timer -= delta
		if pain_timer <= 0:
			if $CollisionShape2D/Pain.visible:
				$CollisionShape2D/Pain.visible = false
				pain_timer = 0
			else:
				$CollisionShape2D/Pain.visible = true
				pain_timer = 0.5
	
	
	if sp == 0: return
	
	if Input.is_action_just_pressed("Swing"):
		coop_swing()
	
	if not is_on_floor():
		velocity += fallSpeed * Vector2.DOWN * delta
		if velocity.y > jump * 2:
			velocity.y = jump * 2
		#elif velocity.y < jump:
			#velocity.y = jump

	if Input.is_action_pressed("Jump") and is_on_floor():
		velocity.y = -jump
	
	var xRaw: float = Input.get_axis("Left", "Right")
	# yRaw: float = Input.get_axis("Up", "Down")
	
	var dir := Vector2(xRaw, 0)
	if dir:
		velocity.x = move_toward(velocity.x, dir.x * speed, accel * delta)
		if dir.x * pivot.scale.x < 0: pivot.scale.x *= -1
	elif is_on_floor():
		velocity.x = move_toward(velocity.x, 0, accel * delta)
	move_and_slide()
	
	if Input.is_action_just_pressed("Cheer"):
		rpc("cheer")
		cheering.emit()

var cheer_timer: float
@rpc("authority", "call_local")
func cheer():
	if $CollisionShape2D/Cheer.visible:
		$CollisionShape2D/Cheer.visible = false
		cheer_timer = 0.075
	else:
		$CollisionShape2D/Cheer.visible = true
		cheer_timer = 0.5

var pain_timer: float
@rpc("authority", "call_local")
func damage_feedback():
	if $CollisionShape2D/Pain.visible:
		$CollisionShape2D/Pain.visible = false
		pain_timer = 0.075
	else:
		$CollisionShape2D/Pain.visible = true
		pain_timer = 0.5
