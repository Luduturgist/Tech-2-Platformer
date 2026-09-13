extends Button

@export var submenu: PackedScene
@export var submenu_path: String

func _ready():
	pressed.connect(_open_submenu)

func _open_submenu():
	var menu
	if submenu:
		menu = submenu.instantiate()
	else:
		menu = load(submenu_path).instantiate()
	add_child(menu)
