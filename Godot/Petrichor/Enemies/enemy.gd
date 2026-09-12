extends CharacterBody2D
class_name Enemy

@export var health: int = 5
@export var damage: int = 1
@export var speed: float = 100
@export var damage_feedback: Node2D
@export var collider: CollisionShape2D
@export var detection_range: Area_Detector

signal damage_taken
var tracking_enemy: bool

func _ready() -> void:
	damage_taken.connect(_show_damage)
	
	if multiplayer.is_server():
		if not detection_range:
			return
		detection_range.target_found.connect(track_target.bind(true))
		detection_range.field_clear.connect(track_target.bind(false))

func track_target(value: bool):
	tracking_enemy = value

var damage_vfx_timer: float = 0
func _show_damage():
	if not damage_feedback.visible:
		damage_feedback.visible = true
		damage_vfx_timer = 0.5
	else:
		damage_vfx_timer = -0.1
		damage_feedback.visible = false

var last_pos: Vector2
func _physics_process(_delta: float) -> void:
	if not is_multiplayer_authority():
		return
	
	if tracking_enemy:
		velocity.x = move_toward(global_position.x, detection_range._nearest_target(global_position).global_position.x, speed * _delta)
		move_and_slide()
	
	if last_pos != position and Wrapper.scene_synchronized:
		_update_position.rpc(position)
		last_pos = position

func _process(delta: float) -> void:
	if damage_vfx_timer > 0:
		damage_vfx_timer -= delta
		if damage_vfx_timer <= 0:
			damage_vfx_timer = 0
			damage_feedback.visible = false
	elif damage_vfx_timer < 0:
		damage_vfx_timer += delta
		if damage_vfx_timer >= 0:
			damage_vfx_timer = 0.5
			damage_feedback.visible = true

func _take_damage(amount: int):
	process_damage(amount)
	rpc("_network_damage", amount)
	damage_taken.emit()

func process_damage(amount: int):
	if is_multiplayer_authority():
		health -= amount
		if health <= 0:
			rpc("kill_enemy")

@rpc("authority", "call_remote", "unreliable_ordered")
func _update_position(pos: Vector2):
	position = pos

@rpc("any_peer", "call_remote", "reliable")
func _network_damage(amount: int):
	damage_taken.emit()
	process_damage(amount)

@rpc("authority", "call_local", "reliable")
func kill_enemy():
	damage_feedback.visible = true
	damage_vfx_timer = 0
	var t = get_tree().create_tween()
	t.tween_property(self, "rotation_degrees", 90, 0.4)
	await t.finished
	queue_free()
