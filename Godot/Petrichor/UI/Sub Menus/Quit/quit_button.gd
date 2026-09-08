extends Button

const QUIT_PATHWAY = "res://UI/Sub Menus/Quit/quit_popup.tscn"
var prefab: PackedScene

func _ready() -> void:
	pressed.connect(_try_quit)
	prefab = load(QUIT_PATHWAY)

func _try_quit():
	add_child(prefab.instantiate())
