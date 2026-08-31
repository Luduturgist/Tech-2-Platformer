extends CanvasLayer
class_name Pause_Menu

func _ready() -> void:
	$Quit.pressed.connect(_quit)
	$"Main Menu".pressed.connect(_menu)
	$"Resume".pressed.connect(_resume)

func _quit():
	get_tree().quit()

func _menu():
	Wrapper._disconnect()

func _resume():
	visible = false
