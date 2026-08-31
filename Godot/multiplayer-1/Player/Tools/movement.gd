@icon("res://Player/Soil/Soil.png")
extends CharacterBody2D
class_name PlayerMovement

@export var friendly: Action
@export var pain_feedback: Action
@export var move_ability: Action = Swing_Action.new()
@export var golem: Golem

@export_group("Settings")
@export var speed: float = 100
@export var accel: float = 800
@export var jump: float = 300
@export var fallSpeed: int = 1150
@export var health: int = 3

@export_group("References")
@export var pivot: Node2D

var sp: float = 0
var energy: Energy
static var active: PlayerMovement
var local: bool
signal interact

enum Golem {Soil, River}

func _ready() -> void:
	if friendly: friendly._start(self)
	if pain_feedback: pain_feedback._start(self)

func dress() -> void:
	active = self
	local = true
	collision_layer = 1
	collision_mask = 1
	visibility_layer = 1
	z_index += 1
	energy = Energy.new(self)
	move_ability._start(self)

func _take_damage(amount: int = 1):
	if not local: return
	health -= amount
	if pain_feedback: pain_feedback._perform_action()
	if health <= 0:
		Wrapper._load_scene("res://Debug/debug_spikes.tscn")

func _physics_process(delta: float) -> void:
	if friendly: friendly._update(delta)
	if pain_feedback: pain_feedback._update(delta)
	
	if not local: return
	
	energy._update(delta)
	move_ability._update(delta)
	
	if Input.is_action_just_pressed("Swing"): move_ability._perform_action()
	if Input.is_action_just_pressed("Cheer") && friendly: friendly._perform_action()
	
	if Input.is_action_just_pressed("Jump") and is_on_floor(): velocity.y = -jump
	
	if Input.is_action_just_pressed("Interact"): interact.emit()
	
	process_move(delta)

func process_move(delta: float):
	if not is_on_floor():
		velocity += fallSpeed * Vector2.DOWN * delta
		if velocity.y > jump * 2:
			velocity.y = jump * 2
		#elif velocity.y < jump:
			#velocity.y = jump
	
	var xRaw: float = Input.get_axis("Left", "Right")
	# yRaw: float = Input.get_axis("Up", "Down")
	var dir := Vector2(xRaw, 0)
	
	if dir:
		velocity.x = move_toward(velocity.x, dir.x * speed, accel * delta)
		if dir.x * pivot.scale.x < 0: pivot.scale.x *= -1
	elif is_on_floor():
		velocity.x = move_toward(velocity.x, 0, accel * delta)
	move_and_slide()
