extends Area2D
class_name Damage_Area

@export var damage: int = 1
@export var damage_interval: float = 0.75
@export var destroy_on_collision = true
@export var ignore: Array[Node2D]
@export var blockable: bool = true
@export var enabled: bool = true
signal impact(pos_x: float)
var impacted_body: Node2D
signal damage_blocked(pos_x: float)

func _ready() -> void:
	body_entered.connect(try_damage_body)

var dmg_timer: float
func _process(delta: float) -> void:
	if dmg_timer > 0:
		if overlaps_body(impacted_body):
			print("mebbie *v*")
			dmg_timer -= delta
			if dmg_timer <= 0:
				dmg_timer += damage_interval
				try_damage_body(impacted_body)
		else:
			impacted_body = null
			dmg_timer = 0
			print("sad ;-;")

func try_damage_body(body: Node2D):
	if ignore.size():
		for i in ignore:
			if i == body:
				return
	if body.is_multiplayer_authority() and body is PlayerMovement:
		_hit_obstacle(body)
		await get_tree().process_frame
		if enabled and (not blocked or not blockable):
			body._take_damage(damage, global_position.x)
		blocked = false
		dmg_timer += damage_interval

var blocked: bool = false
func _hit_obstacle(body: Node2D, blocking: bool = false) -> int:
	impacted_body = body
	impact.emit(body.global_position.x)
	if blockable:
		blocked = blocking
		if blocking:
			damage_blocked.emit(body.global_position.x)
	if destroy_on_collision:
		rpc("disappear")
	return damage

@rpc("any_peer", "call_local", "reliable")
func disappear():
	await get_tree().process_frame
	call_deferred("queue_free")
