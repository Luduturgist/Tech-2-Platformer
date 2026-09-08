@abstract
extends CanvasLayer
class_name Sub_Menu

@export var close_button: Button

func _ready():
	if close_button: close_button.pressed.connect(MenuHandler._try_close_menu)
	MenuHandler._new_submenu(self)

@abstract func _unfocus()

@abstract func _refocus()

func _close():
	call_deferred("queue_free")
