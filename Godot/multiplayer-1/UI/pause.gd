extends CanvasLayer

func _ready() -> void:
	$Quit.pressed.connect(_quit)
	$"Main Menu".pressed.connect(_menu)

func _quit():
	get_tree().quit()

func _menu():
	pass
