extends Node

var sub_menus: Array[Sub_Menu]

func _ready():
	get_tree().scene_changed.connect(_clear_scene)

func _clear_scene():
	if not sub_menus.size(): return
	for menu in sub_menus:
		if menu:
			menu.call_deferred("queue_free")


func _new_submenu(menu: Sub_Menu):
	if sub_menus.size(): sub_menus.back()._unfocus()
	sub_menus.append(menu)
	#menu.layer = sub_menus.size()
	menu.layer += 1 + sub_menus.size()
	if menu.get_parent():
		menu.reparent(self)
	else:
		add_child(menu)
	var backing = load("res://UI/Sub Menus/menu_backing.tscn").instantiate()
	menu.add_child(backing)
	menu.call_deferred("move_child", backing, 0)


func _try_close_menu() -> bool:
	if sub_menus.size():
		sub_menus.pop_back()._close()
		if sub_menus.size():
			sub_menus.back()._refocus()
		return true
	return false
