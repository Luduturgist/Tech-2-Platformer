extends CanvasLayer
class_name Pause_Menu

@export var menu_button: Button
@export var resume_button: Button

func _ready() -> void:
	menu_button.pressed.connect(_menu)
	resume_button.pressed.connect(_pause)
	PlayerInput.close_root.connect(_pause)
	_pause(false)

func _pause(value: bool = true):
	if value and not visible:
		visible = true
		PlayerInput.moving = false
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		visible = false
		PlayerInput.moving = true
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _menu():
	Wrapper._end_session()
