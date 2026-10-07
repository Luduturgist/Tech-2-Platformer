extends Area2D
class_name Brace_Object

@export var per_hit_drain: int = 1

signal brace_released

func _ready() -> void:
	area_entered.connect(try_player)

func try_player(area: Area2D):
	if area is Damage_Area:
		var blocked: bool = (area.global_position.x - global_position.x) * PlayerMovement.active.pivot.scale.x >= 0
		print("block " + str(blocked))
		area._hit_obstacle(self, blocked)

@rpc("authority", "call_local", "reliable")
func set_brace(time: float = 0):
	set_brace_variables(true)
	if time > 0:
		brace_timer = time
		return
	elif time < 0:
		set_brace_variables(false)
		brace_released.emit()

var brace_timer: float = 0
@export var drain_interval: float = 0
var drain_timer: float
func _process(delta: float) -> void:
	if brace_timer > 0:
		brace_timer -= delta
		if brace_timer <= 0:
			set_brace_variables(false)
			brace_released.emit()
	
	if visible and drain_interval > 0:
		drain_timer -= delta
		if drain_timer <= 0:
			drain_timer += drain_interval
			Game_Scene.active.local.energy._drain_charge(1)

func set_brace_variables(value: bool):
	visible = value
	#if is_multiplayer_authority():
		#print("happened")
	$CollisionShape2D.disabled = not value
	drain_timer = drain_interval

func _block_attack():
	print("blocking123")
	
	if is_multiplayer_authority():
		network_block()
	else:
		rpc("network_block")

@rpc("any_peer", "call_remote", "reliable")
func network_block():
	$"../../..".energy._drain_charge(per_hit_drain)
