extends Event_Object
class_name Flash_Object

func _trigger_event():
	rpc("flash")

var flash_timer: float = 0
func _process(delta: float) -> void:
	if not obj: return
	if flash_timer > 0:
		flash_timer -= delta
		if flash_timer <= 0:
			if obj.visible:
				obj.visible = false
				flash_timer = 0
			else:
				obj.visible = true
				flash_timer = 0.5

@rpc("any_peer", "call_local", "reliable")
func flash():
	if not obj: return
	if obj.visible:
		obj.visible = false
		flash_timer = 0.075
	else:
		obj.visible = true
		flash_timer = 0.5
