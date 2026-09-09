extends Damage_Area

@export var speed: float = 100
@export var lifetime: float = 3
@export var explode_time: float = 0.065
@export var vfx: Node2D

var life: float = 0
func _physics_process(delta: float) -> void:
	life += delta
	if explosion_timer >= 0:
		explosion_timer -= delta
		if explosion_timer <= 0:
			explosion_timer = 0
			queue_free()
	
	if explosion_timer < 0:
		if life >= lifetime:
			impact.emit()
		else:
			position += Vector2.RIGHT.rotated(rotation) * speed * delta
	

func _trigger_impact():
	if explosion_timer < 0:
		var hit: Vector2 = $HitCast.get_collision_point()
		if hit == Vector2.ZERO:
			hit = global_position
			print("not found")
		rpc("_explode", hit)

var explosion_timer: float = -1
@rpc("any_peer", "call_local")
func _explode(hit: Vector2):
	global_position = hit
	global_rotation = 0
	explosion_timer = explode_time
	vfx.set_deferred("visible", true)
	$CollisionShape2D.set_deferred("disabled", true)
