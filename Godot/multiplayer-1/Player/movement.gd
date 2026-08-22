extends CharacterBody2D
class_name Movement

@export var speed: float = 10000
@export var jump: float = -300
@export var cam: PackedScene
var sp: float = 0

func dress() -> void:
	var c: Camera2D = cam.instantiate()
	c.follow = self
	await get_tree().process_frame
	get_parent().add_child(c)
	c.make_current()
	sp = speed

func _physics_process(delta: float) -> void:
	if cheer_timer > 0:
		cheer_timer -= delta
		if cheer_timer <= 0:
			if $Cheer.visible:
				$Cheer.visible = false
				cheer_timer = 0
			else:
				$Cheer.visible = true
				cheer_timer = 0.5
	
	
	if sp == 0: return
	
	
	if not is_on_floor():
		velocity += get_gravity() * delta
		if velocity.y > -jump * 2: velocity.y = -jump * 2

	if Input.is_action_pressed("Jump") and is_on_floor():
		velocity.y = jump
	
	var xRaw: float = Input.get_axis("Left", "Right")
	# yRaw: float = Input.get_axis("Up", "Down")
	
	var dir := Vector2(xRaw, 0)
	if dir:
		velocity.x = move_toward(0, dir.x * speed, speed * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, speed * delta)
	move_and_slide()
	
	if Input.is_action_just_pressed("Cheer"): rpc("cheer")

var cheer_timer: float
@rpc("authority", "call_local")
func cheer():
	if $Cheer.visible:
		$Cheer.visible = false
		cheer_timer = 0.075
	else:
		$Cheer.visible = true
		cheer_timer = 0.5
