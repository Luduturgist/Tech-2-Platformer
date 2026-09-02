extends Button

func _ready() -> void:
	pressed.connect(quit)

func quit():
	get_tree().quit()
