extends Event_Object

@export var push_back: float = 150
@export var push_up: float = 50
@export var cast: ShapeCast2D
@export var attenuation_distance: float = 30
@export var feedback: Flash_Object

var push_multiplier: float = 1
signal hits_calculated(int)

func _trigger_event(value: int = 0):
	rpc("network_push", value, push_multiplier)
	feedback._trigger_event()


@rpc("any_peer", "call_local", "reliable")
func network_push(id: int, mult: float):
	cast.force_shapecast_update()
	var objects: Array = cast.collision_result
	if not objects or not objects.size():
		return
	
	for o in objects:
		var hit = o.get("collider")
		var knockback: Vector2 = hit.global_position - obj.global_position
		#knockback = knockback.normalized() * clamp(attenuation_distance - knockback.length(), 0, INF) * push_back * mult
		
		knockback.x = sign(hit.global_position.x - obj.global_position.x) * push_back
		knockback.y = push_up
		
		var hit_count: float = 0
		
		if hit as PlayerMovement:
			hit_count += 1
			if hit == Game_Scene.active.local:
				hit_count -= 1
				if id != multiplayer.get_unique_id() or id == 0:
					Game_Scene.active.local.velocity += knockback
		
		if hit as Enemy:
			hit_count += 1
			if multiplayer.get_unique_id() == 1:
				hit.velocity += knockback
				if not hit.target:
					var player: PlayerMovement = Game_Scene.active.local
					if id != 1:
						player = Game_Scene.active.friend
					hit.override_target(player)
		
		if id == multiplayer.get_unique_id():
			hits_calculated.emit(hit_count)
