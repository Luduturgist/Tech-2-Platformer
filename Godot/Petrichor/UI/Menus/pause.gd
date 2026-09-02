extends CanvasLayer
class_name Pause_Menu

@export var menu_button: Button
@export var resume_button: Button
@export var quit_button: Button

func _ready() -> void:
	menu_button.pressed.connect(_menu)
	resume_button.pressed.connect(_resume)
	quit_button.pressed.connect(_quit)

func _quit():
	get_tree().quit()

func _menu():
	Wrapper._end_session()

func _resume():
	visible = false
