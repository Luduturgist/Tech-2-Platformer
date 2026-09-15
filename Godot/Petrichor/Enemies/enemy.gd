extends CharacterBody2D
class_name Enemy

@export var health: int = 5
@export var damage: int = 1
@export var speed: float = 50
@export var accel: float = 250
@export var damage_feedback: Node2D
@export var collider: CollisionShape2D
@export var detection_range: Area_Detector
@export var pivot: Node2D
@export var attack_range: float = 25
@export var attack_behavior: EnemyAttackBehavior

signal damage_taken
signal killed
signal start_attack
signal end_attack

var tracking_enemy: bool

func _ready() -> void:
	damage_taken.connect(_show_damage)
	attack_behavior._start(self)
	
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
	if last_pos != position and Wrapper.scene_synchronized:
		_update_position.rpc(position, pivot.scale.x)
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

func _take_damage(amount: int) -> int:
	rpc("_network_damage", amount)
	damage_taken.emit()
	return process_damage(amount)

func process_damage(amount: int) -> int:
	health -= amount
	if health <= 0:
		if is_multiplayer_authority():
			rpc("kill_enemy")
		amount += health
	return amount

@rpc("authority", "call_remote", "unreliable_ordered")
func _update_position(pos: Vector2, sca: int):
	position = pos
	pivot.scale.x = sca

@rpc("any_peer", "call_remote", "reliable")
func _network_damage(amount: int):
	damage_taken.emit()
	process_damage(amount)

@rpc("authority", "call_local", "reliable")
func kill_enemy():
	killed.emit()
	damage_feedback.visible = true
	set_meta("Mortal", false)
	damage_vfx_timer = 0
	var t = get_tree().create_tween()
	t.tween_property(self, "rotation_degrees", 90, 0.4)
	await t.finished
	queue_free()
