extends Event_Object
class_name Flash_Object

@export var flash_time: float = 0.5
@export var flash_repeat_delay: float = 0.075
@export var sfx: AudioStream
@export var attenuation_distance = 500
@export var lock_position: bool = false

var player: AudioStreamPlayer2D
var start_pos: Vector2

func _ready() -> void:
	super._ready()
	
	if sfx:
		player = AudioStreamPlayer2D.new()
		add_child(player)
		player.max_polyphony = 8
		player.stream = sfx
	
	if lock_position:
		start_pos = obj.position

func _trigger_event(value: int = 0):
	if (flash_time == 0 and obj.visible):
		return
	if (flash_time < 0 and not obj.visible):
		return
	
	rpc("flash", value)

var flash_timer: float = 0
func _process(delta: float) -> void:
	if (flash_time == 0 and obj.visible):
		return
	if (flash_time < 0 and not obj.visible):
		return
	
	if not obj: return
	if flash_timer > 0:
		flash_timer -= delta 		
		if flash_timer <= 0:
			if obj.visible:
				obj.visible = false
				flash_timer = 0
			else:
				obj.visible = true
				flash_timer = flash_time
				if sfx:
					player.play()
				if lock_position:
					obj.position = start_pos
					lock_pos = obj.global_position


var lock_pos: Vector2
func _physics_process(delta: float) -> void:
	if lock_position and flash_time > 0 and obj.visible:
		obj.global_position = lock_pos

@rpc("any_peer", "call_local", "reliable")
func flash(toggle: int = 0):
	if flash_time == 0:
		obj.visible = true
		return
	elif flash_time < 0:
		obj.visible = false
		return
	
	if not obj: return
	
	if toggle != 0:
		if toggle > 0:
			obj.visible = true
		elif toggle < 0:
			obj.visible = false
		flash_timer = 0
		return
	
	if obj.visible:
		obj.visible = false
		flash_timer = flash_repeat_delay
	else:
		obj.visible = true
		flash_timer = flash_time
		if sfx:
			player.play()
		if lock_position:
			obj.position = start_pos
			lock_pos = obj.global_position
