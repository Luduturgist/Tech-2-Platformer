extends Interacteable

@export var ability_sprite: Sprite2D
@export var ability: Action
@export var type: ability_type
@export var event_triggers: Array[Event_Object]
@export var dependency: Hold_Interact
@export var helper_label: Label
@export var helper_text: String

var tooken: bool = false

enum ability_type {
	Friendly,
	Movement,
	Brace,
	Impact,
	Attack
}

func _ready() -> void:
	super._ready()
	interacted.connect(try_add_ability)

func try_add_ability():
	var depend: bool = not dependency or dependency.pressed
	
	if tooken or not depend:
		return
	
	var player = PlayerMovement.active
	var input: Signal
	
	match type:
		ability_type.Friendly:
			if not player.friendly:
				player.friendly = ability
				input = PlayerInput.player_interact
			else:
				return
		ability_type.Movement:
			if not player.move_ability:
				player.move_ability = ability
				input = PlayerInput.player_special_movement
			elif not player.move_ability.can_push:
				player.move_ability.can_push = true
			else:
				return
		ability_type.Brace:
			if not player.brace:
				player.brace = ability
				input = PlayerInput.player_brace
			else:
				return
		ability_type.Impact:
			if not player.impact_action:
				player.impact_action = ability
			else:
				return
		ability_type.Attack:
			if not player.attack:
				player.attack = ability
				input = PlayerInput.player_attack
			else:
				return
	
	rpc("disable_bestowal")
	
	ability._start(player, input)
	dependency._exhaust()
	
	if event_triggers.size():
		for event in event_triggers:
			event._trigger_event()

@rpc("call_local", "reliable", "any_peer")
func disable_bestowal():
	ability_sprite.visible = false
	tooken = true
	helper_label.visible = true
	helper_label.text = helper_text
	print("done tick")
