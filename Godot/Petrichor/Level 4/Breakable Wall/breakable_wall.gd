extends Pushable
class_name Pushable_Wall

@export var push_fx: AnimatedSprite2D
@export var wall_graphic: Node2D
@export var wall_collider: CollisionShape2D
@export var destruction_sfx: AudioStream

var player: AudioStreamPlayer2D

func _ready() -> void:
	player = AudioStreamPlayer2D.new()
	add_child(player)

func _push_object(dir: int):
	if not pushed:
		rpc("destroy_wall", dir)
		pushed = true

@rpc("any_peer", "call_local", "reliable")
func destroy_wall(dir: int):
	if pushed:
		return
	
	pushed = true
	if push_fx:
		push_fx.play()
	wall_graphic.visible = false
	wall_collider.disabled = true
	if destruction_sfx:
		player.stream = destruction_sfx
		player.play()
