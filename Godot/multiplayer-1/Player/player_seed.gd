extends Node2D

@export var player: PackedScene

@rpc("authority", "call_local")
func init(dress: bool):
	var avatar: Movement = player.instantiate()
	if dress:
		avatar.dress()

	call_deferred("add_child", avatar)
