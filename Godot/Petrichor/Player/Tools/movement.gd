@icon("res://Player/Soil/Soil.png")
extends CharacterBody2D
class_name PlayerMovement

@export var golem: Golem

@export_group("Settings")
@export var move_speed: float = 100
@export var accel: float = 800
@export var jump: float = 300
@export var fallSpeed: int = 1150

@export_group("Actions")
@export var friendly: Action
@export var pain_feedback: Action
@export var move_ability: Action
@export var brace: Action
var taking_action: bool = false

@export_group("References")
@export var pivot: Node2D
@export var collider: CollisionShape2D

var energy: Energy
var pain: Energy
var health: Energy
static var active: PlayerMovement
var local: bool
signal interact
var speed_mods: Dictionary[String, float]

enum Golem {Soil, River}


func _ready() -> void:
	if friendly: friendly._start(self)
	if pain_feedback: pain_feedback._start(self)

func dress() -> void:
	print(name + " dressed by " + str(multiplayer.get_unique_id()))
	active = self
	local = true
	collision_layer = 1
	collision_mask = 1
	visibility_layer = 1
	z_index += 1
	energy = Energy.new(self)
	health = Energy.new(self)
	pain = Energy.new(self)
	move_ability._start(self)
	brace._start(self)
	set_meta(Game.COMBAT_METADATA, true)

func _take_damage(amount: int = 1):
	if not local: return
	print("Damage tooken")
	health._drain(amount)
	if pain_feedback: pain_feedback._perform_action()
	if health.value <= 0:
		Wrapper._load_scene(get_tree().current_scene.scene_file_path)

var can_jump: bool = true

func _physics_process(delta: float) -> void:
	if friendly: friendly._update(delta)
	if pain_feedback: pain_feedback._update(delta)
	
	if not local: return
	
	if Input.is_action_just_pressed("Jump") and is_on_floor() and can_jump: velocity.y = -jump
	if Input.is_action_just_released("Brace"): brace._release_action()
	move_ability._update(delta)
	energy._update(delta)
	process_move(delta)
	
	if taking_action: return
	
	if Input.is_action_just_pressed("Swing"): move_ability._perform_action()
	if Input.is_action_just_pressed("Cheer"): friendly._perform_action()
	if Input.is_action_just_pressed("Brace"): brace._perform_action()
	
	
	if Input.is_action_just_pressed("Interact"): interact.emit()
	

var can_move: bool = true
func process_move(delta: float):
	if not is_on_floor():
		velocity += fallSpeed * Vector2.DOWN * delta
		if velocity.y > jump * 2:
			velocity.y = jump * 2
	
	var xRaw: float = Input.get_axis("Left", "Right")
	# yRaw: float = Input.get_axis("Up", "Down")
	var dir := Vector2(xRaw, 0)
	
	var speed = move_speed
	if speed_mods.size() > 0:
		for m in speed_mods.values():
			dir *= m
	
	if dir and not taking_action and can_move:
		velocity.x = move_toward(velocity.x, dir.x * speed, accel * delta)
		if dir.x * pivot.scale.x < 0:
			pivot.scale.x *= -1
			collider.position.x *= -1
	elif is_on_floor():
		var drag := accel * delta
		if velocity.x > move_speed:
			drag *= velocity.x / move_speed
		velocity.x = move_toward(velocity.x, 0, drag)
	move_and_slide()
