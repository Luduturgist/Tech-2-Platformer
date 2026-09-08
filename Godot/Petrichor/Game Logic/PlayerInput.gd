extends Node

var player_movement: Vector2 = Vector2.ZERO
var movement_raw: Vector2 = Vector2.ZERO

signal player_jump
signal player_interact
signal player_brace
signal player_special_movement
signal player_cheer
signal player_debug

signal close_root

var moving: bool = false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Back"):
		if not MenuHandler._try_close_menu():
			close_root.emit()
	
	var x = Input.get_axis("Left", "Right")
	var y = Input.get_axis("Down", "Up")
	movement_raw = Vector2(x, y)
	
	if not moving:
		player_movement = Vector2.ZERO
	else:
		player_movement = movement_raw
		
		if Input.is_action_just_pressed("Jump"):
			player_jump.emit()
		
		if Input.is_action_just_pressed("Cheer"):
			player_cheer.emit()
		
		if Input.is_action_just_pressed("Swing"):
			player_special_movement.emit()
		
		if Input.is_action_just_pressed("Interact"):
			player_interact.emit()
		
		if Input.is_action_just_pressed("Brace"):
			player_brace.emit()
		
		if Input.is_action_just_pressed("Debug"):
			player_debug.emit()
		
		
