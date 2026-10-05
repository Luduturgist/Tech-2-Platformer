extends Shy_Submenu

@export var auto_button: Button
@export var keyboard_button: Button
@export var controller_button: Button

var inputs: Array[Button]
var active: int

func _ready():
	super._ready()
	auto_button.pressed.connect(_switch_input.bind(PlayerInput.input_type.NONE))
	keyboard_button.pressed.connect(_switch_input.bind(PlayerInput.input_type.INPUT_KEYBOARD))
	controller_button.pressed.connect(_switch_input.bind(PlayerInput.input_type.INPUT_CONTROLLER))
	
	inputs.append(auto_button)
	inputs.append(keyboard_button)
	inputs.append(controller_button)
	
	for b in inputs:
		b.toggle_mode = true
	
	_switch_input(PlayerInput.input_override)

func _switch_input(type: PlayerInput.input_type):
	PlayerInput.input_override = type
	inputs[active].button_pressed = false
	inputs[type].button_pressed = true
	active = type
