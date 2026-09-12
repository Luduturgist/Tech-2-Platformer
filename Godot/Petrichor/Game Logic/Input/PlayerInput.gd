extends Control

var player_movement: Vector2 = Vector2.ZERO
var movement_raw: Vector2 = Vector2.ZERO

signal player_jump
signal player_interact
signal player_brace
signal player_special_movement
signal player_debug

signal close_root

var moving: bool = false
var controller_input: bool = false

@onready var controller_input_strings: Input_Names = preload("uid://bvmc34sxc70s8")
@onready var keyboard_input_strings: Input_Names = preload("uid://cklr7nip6iu65")

@onready var controller_swap_inputs: Array[String] = controller_input_strings._get_buttons()
@onready var keyboard_swap_inputs: Array[String] = keyboard_input_strings._get_buttons()

var pause_time: float = 0
func _pause_movement(time: float):
	player_movement = Vector2.ZERO
	if time > pause_time:
		pause_time = time

func _process(_delta: float) -> void:
	
	if pressed_back:
		pressed_back = false
	
	if pause_time > 0:
		pause_time -= _delta
		if pause_time <= 0:
			pause_time = 0
	
	_try_for_input_switch()
	
	if Input.is_action_just_pressed("Debug"):
		player_debug.emit()
	
	if controller_input and DisplayServer.window_is_focused():
		if Input.is_action_just_pressed("Controller Menu") or (not moving and Input.is_action_just_pressed("Controller Brace")):
			try_escape()
		process_input(controller_input_strings)
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			var new_mouse_pos: Vector2 = get_viewport().get_mouse_position()
			print(str(new_mouse_pos) + ", " + str(get_global_mouse_position()))
			Input.warp_mouse(new_mouse_pos)
	else:
		if Input.is_action_just_pressed("Keyboard Menu"):
			try_escape()
		process_input(keyboard_input_strings)
	
	if not moving or pause_time > 0:
		player_movement = Vector2.ZERO
	else:
		player_movement = movement_raw

var pressed_back: bool = false
func try_escape():
	if not MenuHandler._try_close_menu():
		close_root.emit()
	pressed_back = true

func _try_for_input_switch():
	var input_rebels := controller_swap_inputs
	if controller_input:
		input_rebels = keyboard_swap_inputs
	
	for i in input_rebels:
		if Input.is_action_just_pressed(i):
			controller_input = not controller_input
			return

func process_input(input: Input_Names):
	var x = Input.get_axis(input.move_left, input.move_right)
	var y = Input.get_axis(input.move_down, input.move_up)
	movement_raw = Vector2(x, y)
	
	if not moving:
		return
	
	if Input.is_action_just_pressed(input.jump):
		player_jump.emit()
	
	if Input.is_action_just_pressed(input.swing):
		player_special_movement.emit()
	
	if Input.is_action_just_pressed(input.interact):
		player_interact.emit()
	
	if Input.is_action_just_pressed(input.brace) and not pressed_back:
		player_brace.emit()
