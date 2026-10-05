extends Button

const SETTINGS_MENU = preload("uid://xtyaj2ti3of7")

func _pressed() -> void:
	var menu = SETTINGS_MENU.instantiate()
	add_child(menu)
