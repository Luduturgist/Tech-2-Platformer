extends CanvasLayer

@export var menu_button: Button
@export var menu_scene: String

func _ready() -> void:
	menu_button.pressed.connect(return_to_menu)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func return_to_menu():
	get_tree().change_scene_to_file(menu_scene)
