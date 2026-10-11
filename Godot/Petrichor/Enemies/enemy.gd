extends CharacterBody2D
class_name Enemy

@export_group("Stats")
@export var health: int = 2
@export var damage: int = 1
@export var drain: int = 0
@export var speed: float = 75
@export var accel: float = 350
@export var attack_range: float = 25
@export var stun_time: float = 1.3
@export var knockback: Vector2 = Vector2(-75, -50)
@export var fall_speed: float = 30
@export var start_flipped: bool = false
@export var knockback_stun: float = 0.5

@export_group("References")
@export var collider: CollisionShape2D
@export var detection_range: Area_Detector
@export var chase_range: Area_Detector
@export var override_detection_range: Area_Detector
@export var pivot: Node2D
@export var attack_behavior: EnemyAttackBehavior
@export var attack_source: Node2D
@export var damage_cast: ShapeCast2D
@export var animator: AnimatedSprite2D

@export_group("VFX")
@export var stun_feedback: Node2D
@export var windup_feedback: Node2D
@export var attack_feedback: Node2D


@export_group("SFX")
@export var attack_sfx: AudioStream = preload("res://Enemies/SFX/Attack.wav")
@export var damage_sfx: AudioStream = preload("res://Player/SFX/Player_AttackHit.wav")

@export_group("death")
@export var live_sprite: Node2D
@export var death_sprite: Node2D
@export var growth_sprite: Sprite2D
@export var death_events: Array[Event_Object]
@export var fertilizer_events: Array[Event_Object]
@export var redlight: Node2D
@export var interactable: Hold_Interact
@export var grown_color: Color = Color(0.482, 0.89, 0.494, 1.0)
@export var last_flash_time: float = 2.7

var audio_player: AudioStreamPlayer2D
var playback: AudioStreamPlaybackPolyphonic

signal damage_taken
signal stunned
signal killed
@warning_ignore("unused_signal")
signal start_attack
@warning_ignore("unused_signal")
signal end_attack
signal update_tracking(bool)
signal update_stun(bool)
signal fertilized


var tracking_enemy: bool
var target: Node2D

func enemy_can_move() ->  bool:
	return tracking_enemy and health > 0 and stun_timer == 0 and knockback_timer == 0

func _ready() -> void:
	audio_player = $"AudioStreamPlayer2D"
	audio_player.play()
	playback = audio_player.get_stream_playback()
	
	if not attack_source:
		attack_source = self
	
	if attack_behavior:
		attack_behavior._start(self)
	
	if start_flipped:
		pivot.scale.x *= -1
	
	update_stun.connect(_show_stun)
	
	if multiplayer.is_server():
		if not detection_range:
			return
		detection_range.target_found.connect(track_target.bind(true))
		chase_range.target_lost.connect(track_target.bind(false))
		stunned.connect(knockback_enemy)
		damage_taken.connect(knockback_enemy)
		override_detection_range.target_found.connect(override_target)

var last_attack_dir: int = 1
var air_knockback_mult: float = 0.5
func knockback_enemy(source: float = -INF):
	if health <= 0:
		return
	
	var local_knockback: Vector2 = knockback
	
	if not is_on_floor():
		local_knockback.x *= air_knockback_mult
	
	if source != -INF:
		last_attack_dir = -sign(source - global_position.x)
		print('happy')
	else:
		print("saedd")
	
	local_knockback.x *= last_attack_dir
	
	velocity += local_knockback
	
	knockback_timer = knockback_stun

func track_target(_value: bool):
	#print("target " + str(value))
	if target and chase_range.targets.find(target) != -1:
		return
	
	target = detection_range._nearest_target()
	
	tracking_enemy = not not target
	rpc("_network_tracking", tracking_enemy)

func override_target(new_target: Node2D = null):
	tracking_enemy = true
	
	if new_target == null:
		target = override_detection_range._nearest_target()
		if target == null:
			tracking_enemy = false
	else:
		target = new_target
	
	rpc("_network_tracking", tracking_enemy)


var last_pos: Vector2
func _physics_process(_delta: float) -> void:
	if not is_multiplayer_authority():
		return
	
	if not is_on_floor():
		velocity.y += fall_speed
	
	if last_pos != position and Wrapper.scene_synchronized:
		_update_position.rpc(position, pivot.scale.x)
		last_pos = position
	
	move_and_slide()

var stun_timer: float
var flash_timer: float
var knockback_timer: float
func _process(delta: float) -> void:
	if last_flash > 0:
		last_flash -= delta
		if last_flash > 0:
			redlight.color.a = last_flash / last_flash_time
		else:
			redlight.visible = false
	
	if knockback_timer > 0:
		knockback_timer -= delta
		if knockback_timer <= 0:
			knockback_timer = 0
			
	
	if stun_timer > 0:
		stun_timer -= delta
		if stun_timer <= 0:
			stun_timer = 0
			update_stun.emit(false)
	

func _take_damage(amount: int, source: float) -> int:
	print("dmg")
	rpc("_network_damage", amount, sign(source - global_position.x), int(Wrapper.local_type))
	#await damage_taken
	
	var temp: int = health
	temp -= amount
	if temp < 0: amount += temp
	return amount

func process_damage(amount: int, player: int) -> int:
	health -= amount
	if health <= 0:
		if is_multiplayer_authority():
			rpc("kill_enemy")
		amount += health
	
	if is_multiplayer_authority():
		if player == Wrapper.local_type:
			override_target(Game_Scene.active.local)
		else:
			override_target(Game_Scene.active.friend)
	
	damage_taken.emit()
	play_sfx(damage_sfx)
	
	return amount

func _show_stun(value: bool):
	stun_feedback.visible = value

func play_sfx(stream: AudioStream):
	var i: int = playback.play_stream(stream)
	var pitch_range: float = 8
	var rand: float = ((100 - (pitch_range / 2)) + (pitch_range * randf())) / 100
	playback.set_stream_pitch_scale(i, rand)

@rpc("authority", "call_remote", "unreliable_ordered")
func _update_position(pos: Vector2, sca: int):
	position = pos
	pivot.scale.x = sca

@rpc("authority", "call_local", "reliable")
func _network_tracking(value: bool):
	update_tracking.emit(value)

@rpc("any_peer", "call_local", "reliable")
func _network_damage(amount: int, source: int, player: int):
	last_attack_dir = source

	if health > 0:
		process_damage(amount, player)
	
	elif interactable.pressed:
		print("lol")
		fertilizer_action()

@rpc("authority", "call_local", "reliable")
func _network_stun():
	stun_timer = stun_time
	update_stun.emit(true)
	stunned.emit()

@rpc("authority", "call_local", "reliable")
func kill_enemy():
	killed.emit()
	fertilizer_death()

	
	#queue_free()

@rpc("authority", "call_local", "reliable")
func perform_attack():
	attack_behavior._attack_start()
	await end_attack
	attack_behavior._attack_end()

func fertilizer_death():
	live_sprite.visible = false
	death_sprite.visible = true
	attack_feedback.visible = false
	windup_feedback.visible = false
	redlight.visible = true
	interactable.enabled = true
	
	if death_events.size():
		for event in death_events:
			event._trigger_event()

var last_flash: float
func fertilizer_action():
	fertilized.emit()
	death_sprite.visible = false
	growth_sprite.visible = true
	set_meta("Mortal", false)
	redlight.visible = false
	interactable.enabled = false
	interactable.pressed = false
	interactable.rpc("button_interact", false)
	redlight.color = grown_color
	last_flash = last_flash_time
	
	if fertilizer_events.size():
		for event in fertilizer_events:
			event._trigger_event()

var current_animation: int = 0
func try_swap_animation(anim: int):
	if anim == current_animation:
		return
	
	current_animation = anim
	rpc("network_anim", anim)

@rpc("call_local", "authority", "reliable")
func network_anim(anim: int):
	current_animation = anim
	var animation: StringName = &"Idle"
	match anim:
		0:
			animation = &"Idle"
		1:
			animation = &"Run"
		2:
			animation = &"Attack"
	
	animator.animation = animation
	animator.play()

func debug_death():
	var t = get_tree().create_tween()
	t.tween_property(self, "rotation_degrees", -90 * last_attack_dir, 0.4)
	await t.finished
	queue_free()
