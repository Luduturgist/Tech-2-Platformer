extends CharacterBody2D

@export var speed: float = 10000
@export var cam: PackedScene

func _ready() -> void:
	var c: Camera2D = cam.instantiate()
	c.follow = self
	await get_tree().process_frame
	get_parent().add_child(c)
	c.make_current()

func _physics_process(delta: float) -> void:
	var xRaw: float = Input.get_axis("Left", "Right")
	var yRaw: float = Input.get_axis("Up", "Down")
	
	var dir := Vector2(xRaw, yRaw) * speed * delta
	velocity = dir
	move_and_slide()
