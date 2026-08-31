extends Node
class_name Flash_Object

var obj

func _ready() -> void:
	var s = self
	if s is Control:
		obj = s
	elif s is Node2D:
		obj = s

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

@rpc("any_peer", "call_local")
func flash():
	if not obj: return
	if obj.visible:
		obj.visible = false
		flash_timer = 0.075
	else:
		obj.visible = true
		flash_timer = 0.5
