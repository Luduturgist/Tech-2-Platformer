extends Damage_Area

@export var speed: float = 100
@export var lifetime: float = 3
@export var explode_time: float = 0.065
@export var vfx: Node2D
@export var raycast: RayCast2D

var life: float = 0
func _physics_process(delta: float) -> void:
	life += delta
	if explosion_timer >= 0:
		explosion_timer -= delta
		if explosion_timer <= 0:
			explosion_timer = 0
			if multiplayer.is_server():
				queue_free()
			else:
				visible = false
	
	if explosion_timer < 0:
		if life >= lifetime:
			impact.emit()
		else:
			position += Vector2.RIGHT.rotated(rotation) * speed * delta
	

func _trigger_impact():
	if explosion_timer < 0:
		if impacted_body:
			look_at(impacted_body.global_position)
			var mask = raycast.collision_mask
			match impacted_body.get_script():
				TileSet:
					mask = impacted_body.get_physics_layer_collision_layer()
				Area2D:
					mask = impacted_body.collision_mask
			raycast.collision_mask = mask
		var hit: Vector2 = $HitCast.get_collision_point()
		if hit == Vector2.ZERO:
			hit = global_position
		#rpc("_explode", hit)
		rpc("_explode")

var explosion_timer: float = -1
@rpc("any_peer", "call_local")
func _explode(_hit: Vector2 = Vector2.ZERO):
	#global_position = _hit
	global_rotation = 0
	explosion_timer = explode_time
	vfx.set_deferred("visible", true)
	$CollisionShape2D.set_deferred("disabled", true)
