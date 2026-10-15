extends Interacteable

@export var ability_sprite: Sprite2D
@export var ability: Action
@export var type: ability_type
@export var event_triggers: Array[Event_Object]
@export var dependency: Hold_Interact
@export var helper_label: Label
@export var helper_text: String
@export var signal_light: Node2D
@export var available_sfx: AudioStream
@export var unavailable_sfx: AudioStream

@export var display_sprites: Array[Node2D]

var tooken: bool = false

enum ability_type {
	Brace,
	Swing,
	Push
}

func _ready() -> void:
	super._ready()
	interacted.connect(try_add_ability)
	display_sprites[type].visible = true
	dependency.activated.connect(availability_feedback.bind(true))
	dependency.deactivated.connect(availability_feedback.bind(false))

func availability_feedback(value: bool):
	signal_light.visible = value
	if value:
		if available_sfx:
			$AudioStreamPlayer2D.play(available_sfx)
	else:
		if unavailable_sfx:
			$AudioStreamPlayer2D.play(unavailable_sfx)

func try_add_ability():
	var depend: bool = not dependency or dependency.pressed
	
	if tooken or not depend:
		return
	
	var player = PlayerMovement.active
	var input: Signal
	
	match type:
		ability_type.Brace:
			if not player.friendly:
				player.friendly = ability
				input = PlayerInput.player_interact

		ability_type.Swing:
			if not player.move_ability:
				player.move_ability = ability
				input = PlayerInput.player_special_movement
		ability_type.Push:
			player.move_ability.can_push = true
	
	rpc("disable_bestowal")
	
	ability._start(player, input)
	dependency._exhaust()
	
	if event_triggers.size():
		for event in event_triggers:
			event._trigger_event()

@rpc("call_local", "reliable", "any_peer")
func disable_bestowal():
	ability_sprite.visible = false
	signal_light.visible = false
	tooken = true
	helper_label.visible = true
	helper_label.text = helper_text
	print("done tick")
