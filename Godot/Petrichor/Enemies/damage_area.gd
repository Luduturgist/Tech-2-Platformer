extends Area2D
class_name Damage_Area

@export var damage: int = 1
@export var destroy_on_collision = true
@export var ignore: Array[Node2D]
signal impact()

func _ready() -> void:
	body_entered.connect(try_damage_body)
	impact.connect(_trigger_impact)

func try_damage_body(body: Node2D):
	if blocked: return
	if ignore.size():
		for i in ignore:
			if i == body:
				return
	if body.is_multiplayer_authority():
		_hit_obstacle(body)
		if Game_Scene.check_combat(body):
			await get_tree().process_frame
			if not blocked:
				body._take_damage(damage)

var blocked: bool = false
func _hit_obstacle(body: Node2D, blocking: bool = false) -> int:
	if blocking:
		blocked = true
	if destroy_on_collision:
		impact.emit()
	return damage

func _trigger_impact():
	rpc("disappear")

@rpc("any_peer", "call_local", "reliable")
func disappear():
	await get_tree().process_frame
	call_deferred("queue_free")
