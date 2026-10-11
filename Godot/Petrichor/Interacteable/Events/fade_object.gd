extends Event_Object
class_name Fade_Object

@export var fade_time: float = 2
var start_energy: float
@export var player: PlayerMovement
signal fade_ended

func _ready() -> void:
	super._ready()
	start_energy = obj.energy

func _trigger_event(_value: int = 0):
	if not obj.visible:
		#var mod: float = fade_time * (float(Game_Scene.active.local.energy.charge) / float(Game_Scene.active.local.energy.maxCharge))
		#var mod: float = fade_time * ((float(Game_Scene.active.local.energy.maxCharge) - float(Game_Scene.active.local.energy.pain)) / float(Game_Scene.active.local.energy.maxCharge))
		#print(mod)
		rpc("fade", fade_time)

var fade_mod: float = 1
var fade_timer: float = 0
func _process(delta: float) -> void:
	if not obj: return
	if fade_timer > 0:
		fade_timer -= delta
		if fade_timer <= 0:
			obj.visible = false
			fade_timer = 0
			fade_ended.emit()
			player.cheering = false
		else:			
			if fade_timer > fade_time / 2 * fade_mod:
				obj.energy = (1 - (fade_timer / fade_time)) * start_energy * fade_mod
			else:
				obj.energy = fade_timer / fade_time * start_energy * fade_mod
		


@rpc("any_peer", "call_local", "reliable")
func fade(_time: float):
	if not obj: return
	
	obj.visible = true
	fade_timer = (1 + _time) / 2
	fade_mod = (1 + _time) / 2
	player.cheering = true
