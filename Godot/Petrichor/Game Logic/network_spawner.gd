extends Node
class_name Network_Spawner

@export var spawn_types: Array[PackedScene]
signal node_spawned(index: int)

var spawned_nodes: int = 0

func start_spawn(type: int):
	spawned_nodes += 1
	rpc("_spawn_node", type, spawned_nodes)

@rpc("any_peer", "call_local", "reliable")
func _spawn_node(type: int, num: int):
	var p = spawn_types[type].instantiate()
	p.name = str(num)
	add_child(p)
	node_spawned.emit(p)
