extends Attack_Lever

@export var river_ability: Action
@export var soil_ability: Action
@export var type: ability_type
@export var event_triggers: Array[Event_Object]
@export var helper_label: Label
@export_multiline() var helper_text: String
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
	flipped.connect(try_add_ability)
	display_sprites[type].visible = true

func availability_feedback(value: bool):
	light.visible = value
	if value:
		if available_sfx:
			$AudioStreamPlayer2D.play(available_sfx)
	else:
		if unavailable_sfx:
			$AudioStreamPlayer2D.play(unavailable_sfx)

func try_add_ability(id: int):
	#print("wha")
	
	var depend: bool = not dependency or dependency.pressed
	
	if tooken or not depend or id != multiplayer.get_unique_id():
		return
	
	var player = PlayerMovement.active
	var input: Signal
	
	var ability
	
	if Wrapper.local_type == Wrapper.Golem.GOLEM_RIVER:
		ability = river_ability
	else:
		ability = soil_ability
	
	match type:
		ability_type.Brace:
			if not player.brace:
				player.brace = ability
				input = PlayerInput.player_brace
				print("braaa")
			else:
				return

		ability_type.Swing:
			if not player.move_ability:
				player.move_ability = ability
				input = PlayerInput.player_special_movement
			else:
				return
		ability_type.Push:
			if not player.move_ability.can_push:
				ability = player.move_ability
				ability.can_push = true
			else:
				return
	
	rpc("disable_bestowal")
	
	if not type == ability_type.Push:
		ability._start(player, input)
	dependency._exhaust()
	
	if event_triggers.size():
		for event in event_triggers:
			event._trigger_event()

@rpc("call_local", "reliable", "any_peer")
func disable_bestowal():
	display_sprites[type].visible = false
	tooken = true
	helper_label.visible = true
	helper_label.text = helper_text
	#print("done tick")
	oneshot = true
	light.visible = false
