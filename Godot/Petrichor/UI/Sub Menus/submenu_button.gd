extends Button

@export var submenu: PackedScene
@export var submenu_path: String

func _ready():
	pressed.connect(_open_submenu)

func _open_submenu():
	if submenu:
		submenu.instantiate()
	else:
		load(submenu_path).instantiate()
