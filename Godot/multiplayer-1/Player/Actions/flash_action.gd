extends Action
class_name Flash_Action

@export var flash_object_path: NodePath
var obj: Flash_Object

func _start(m: PlayerMovement):
	super(m)
	obj = m.get_node(flash_object_path)

func _perform_event():
	obj.rpc("flash")
