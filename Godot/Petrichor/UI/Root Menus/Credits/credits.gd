extends CanvasLayer

@export var menu_button: Button
@export var menu_scene: String

func _ready() -> void:
	TransitionHandler._open_scene()
	menu_button.pressed.connect(return_to_menu)
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func return_to_menu():
	get_tree().change_scene_to_file(menu_scene)
	
