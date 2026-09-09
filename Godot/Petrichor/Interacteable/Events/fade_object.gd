extends Event_Object
class_name Fade_Object

@export var fade_time: float = 2
var start_energy: float
var player: PlayerMovement
signal fade_ended

func _ready() -> void:
	super._ready()
	start_energy = obj.energy

func _trigger_event(_value: int = 0):
	if not obj.visible:
		#var mod: float = fade_time * (float(Game_Scene.active.local.energy.charge) / float(Game_Scene.active.local.energy.maxHealth))
		var mod: float = fade_time * ((float(Game_Scene.active.local.energy.maxHealth) - float(Game_Scene.active.local.energy.pain)) / float(Game_Scene.active.local.energy.maxHealth))
		#print(mod)
		rpc("fade", mod)

var fade_timer: float = 0
func _process(delta: float) -> void:
	if not obj: return
	if fade_timer > 0:
		fade_timer -= delta
		if fade_timer <= 0:
			obj.visible = false
			fade_timer = 0
			fade_ended.emit()
		else:			
			if fade_timer > fade_time / 2:
				obj.energy = (1 - (fade_timer / fade_time)) * start_energy
			else:
				obj.energy = fade_timer / fade_time * start_energy
		


@rpc("any_peer", "call_local", "reliable")
func fade(_time: float):
	if not obj: return
	
	obj.visible = true
	fade_timer = _time
