extends Area2D
class_name Enemy

@export var health: int = 5
@export var damage: int = 1

signal damage_taken

func _take_damage(amount: int):
	process_damage(amount)
	rpc("_network_damage", amount)
	damage_taken.emit()

func process_damage(amount: int):
	if is_multiplayer_authority():
		health -= damage
		if health <= 0:
			rpc("kill_enemy")

@rpc("any_peer", "call_remote", "reliable")
func _network_damage(amount: int):
	damage_taken.emit()
	process_damage(amount)

@rpc("authority", "call_local", "reliable")
func kill_enemy():
	queue_free()
