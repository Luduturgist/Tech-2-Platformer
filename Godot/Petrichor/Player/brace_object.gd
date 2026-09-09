extends Area2D
class_name Brace_Object

signal brace_released

func _ready() -> void:
	area_entered.connect(try_player)

func try_player(area: Area2D):
	if area is Damage_Area:
		area._hit_obstacle(self, true)

@rpc("authority", "call_local", "reliable")
func set_brace(time: float):
	if time == 0:
		set_brace_variables(true)
	else:
		set_brace_variables(true)
		brace_timer = time

var brace_timer: float = 0
func _process(delta: float) -> void:
	if brace_timer > 0:
		brace_timer -= delta
		if brace_timer <= 0:
			set_brace_variables(false)
			brace_released.emit()

func set_brace_variables(value: bool):
	visible = value
	if is_multiplayer_authority():
		print("happened")
		$CollisionShape2D.disabled = not value
