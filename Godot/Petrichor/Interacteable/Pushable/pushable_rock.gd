extends Pushable

@export var speed: float = 100
@export var kickup: float = -20
@export var throw_damage: int = 1
@export var lifetime: float = 0.5
@export var fall_speed: float = 10
@export var impact_vfx: Node2D
@export var vfx_lifetime: float = 0.1
@export var push_sfx: AudioStream
@export var impact_sfx: AudioStream

var velocity: Vector2
var hit: bool = false
var ignore: Node2D

func _push_object(dir: int):
	ignore = Game_Scene.active.local
	rpc("throw_rock", dir)

@rpc("call_local", "any_peer", "reliable")
func throw_rock(dir: int):
	position.y += kickup
	velocity.x = speed * dir
	pushed = true
	if push_sfx:
		$AudioStreamPlayer2D.play(push_sfx)


func _process(delta: float) -> void:
	if not pushed:
		return
	
	if hit:
		return
	
	position += velocity * delta
	position += Vector2(0, fall_speed * delta)
	
	lifetime -= delta
	if lifetime <= 0:
		lifetime = 0
		impact(null)

func _ready():
	body_entered.connect(impact)


func impact(body: Node2D):
	if ignore:
		if ignore == body:
			return
	
	if hit or velocity == Vector2.ZERO:
		return
	
	if body:
		if body.get_meta("Mortal", false) and body.is_multiplayer_authority():
			body._take_damage(throw_damage, body.global_position.x - velocity.x)
		if body is Enemy:
			if body.health <= 0:
				return
	
	rpc("impact_fx", global_position.x)

@rpc("any_peer", "reliable", "call_local")
func impact_fx(pos: float):
	global_position.x = pos
	hit = true
	impact_vfx.visible = true
	
	if impact_sfx:
		$AudioStreamPlayer2D.play(impact_sfx)
	
	await get_tree().create_timer(vfx_lifetime).timeout
	
	queue_free()
