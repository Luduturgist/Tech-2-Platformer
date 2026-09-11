extends Area2D
class_name Enemy

@export var health: int = 5
@export var damage: int = 1
@export var damage_feedback: Node2D

signal damage_taken

func _ready() -> void:
	damage_taken.connect(_show_damage)

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
	queue_free()
