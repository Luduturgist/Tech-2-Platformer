extends Resource
class_name Input_Names

@export var move_up: String
@export var move_down: String
@export var move_left: String
@export var move_right: String
@export var jump: String
@export var interact: String
@export var brace: String
@export var swing: String
@export var menu: String
@export var attack: String

func _get_buttons() -> Array[String]:
	var a: Array[String]
	a.append(move_up)
	a.append(move_down)
	a.append(move_left)
	a.append(move_right)
	a.append(jump)
	a.append(interact)
	a.append(brace)
	a.append(swing)
	a.append(menu)
	a.append(attack)
	
	return a
