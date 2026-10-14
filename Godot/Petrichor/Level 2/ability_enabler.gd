extends Interacteable

@export var ability_sprite: Sprite2D
@export var ability: Action
@export var type: ability_type
@export var event_triggers: Array[Event_Object]
@export var dependency: Hold_Interact

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
	if tooken or not dependency.pressed:
		return
	
	rpc("disable_bestowal")
	var player = PlayerMovement.active
	var input: Signal
	
	match type:
		ability_type.Friendly:
			if not player.friendly:
				player.friendly = ability
				input = PlayerInput.player_interact
		ability_type.Movement:
			if not player.move_ability:
				player.move_ability = ability
				input = PlayerInput.player_special_movement
			else:
				player.move_ability.can_push = true
		ability_type.Brace:
			if not player.brace:
				player.brace = ability
				input = PlayerInput.player_brace
		ability_type.Impact:
			if not player.impact_action:
				player.impact_action = ability
		ability_type.Attack:
			if not player.attack:
				player.attack = ability
				input = PlayerInput.player_attack
	
	ability._start(player, input)
	
	if event_triggers.size():
		for event in event_triggers:
			event._trigger_event()

@rpc("call_local", "reliable", "any_peer")
func disable_bestowal():
	ability_sprite.visible = false
	tooken = true
