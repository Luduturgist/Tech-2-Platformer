extends Shy_Submenu

@export var auto_button: Button
@export var keyboard_button: Button
@export var controller_button: Button

func _ready():
	super._ready()
	auto_button.pressed.connect(_switch_input.bind(PlayerInput.input_type.NONE))
	keyboard_button.pressed.connect(_switch_input.bind(PlayerInput.input_type.INPUT_KEYBOARD))
	controller_button.pressed.connect(_switch_input.bind(PlayerInput.input_type.INPUT_CONTROLLER))

func _switch_input(type: PlayerInput.input_type):
	PlayerInput.input_override = type
