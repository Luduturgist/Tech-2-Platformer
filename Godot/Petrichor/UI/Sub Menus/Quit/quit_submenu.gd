extends Sub_Menu

@export var quit_button: Button

func _ready():
	super._ready()
	quit_button.pressed.connect(_quit)

func _quit():
	Wrapper._end_session()
	get_tree().quit()

func _unfocus():
	pass

func _refocus():
	pass
