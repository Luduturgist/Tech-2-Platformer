extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const tile_height = 32

@export var target: Node2D

func _physics_process(delta: float) -> void:
	process_move(delta)

func process_move(delta: float):
		# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

		

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func process_jump():
	velocity.y = JUMP_VELOCITY
