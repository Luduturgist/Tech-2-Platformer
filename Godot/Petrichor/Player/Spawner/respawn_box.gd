extends Node2D

@export var player_prefab: PackedScene
@export var height_offset: int = -16
@export var spawn_on_start: bool = true

var player: PlayerMovement

@rpc("call_local", "reliable")
func _spawn_player():
	player =  player_prefab.instantiate()
	await get_tree().process_frame
	get_tree().current_scene.add_child(player)
	player.global_position.x = global_position.x
	player.position.y = global_position.x + height_offset

func _respawn():
	player.global_position.x = global_position.x
	player.position.y = global_position.x + height_offset
