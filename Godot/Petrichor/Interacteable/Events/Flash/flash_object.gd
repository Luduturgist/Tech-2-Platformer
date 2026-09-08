extends Event_Object
class_name Flash_Object

@export var flash_time: float = 0.5
@export var flash_repeat_delay: float = 0.075

func _trigger_event(value: int = 0):
	if (flash_time == 0 and obj.visible):
		return
	if (flash_time < 0 and not obj.visible):
		return
	
	rpc("flash", value)

var flash_timer: float = 0
func _process(delta: float) -> void:
	if (flash_time == 0 and obj.visible):
		return
	if (flash_time < 0 and not obj.visible):
		return
	
	if not obj: return
	if flash_timer > 0:
		flash_timer -= delta 		
		if flash_timer <= 0:
			if obj.visible:
				obj.visible = false
				flash_timer = 0
			else:
				obj.visible = true
				flash_timer = flash_time

@rpc("any_peer", "call_local", "reliable")
func flash(toggle: int = 0):
	if flash_time == 0:
		obj.visible = true
		return
	elif flash_time < 0:
		obj.visible = false
		return
	
	if not obj: return
	
	if toggle != 0:
		if toggle > 0:
			obj.visible = true
		elif toggle < 0:
			obj.visible = false
		flash_timer = 0
		return
	
	if obj.visible:
		obj.visible = false
		flash_timer = flash_repeat_delay
	else:
		obj.visible = true
		flash_timer = flash_time
