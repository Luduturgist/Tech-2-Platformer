extends Area2D

@export var drain_amount: int = 1
@export var overdraw: Wrapper.Golem = Wrapper.Golem.GOLEM_RIVER
@export var interval: float = 1
@export var enabled: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer = interval


var timer: float = 0
func _process(delta: float) -> void:
	if timer > 0 and enabled:
		timer -= delta
		if timer <= 0:
			timer += interval
			stimulate_player()

func stimulate_player():
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body is PlayerMovement:
			if drain_amount > 0:
				
				if Wrapper.local_type == overdraw or overdraw == Wrapper.Golem.UNASSIGNED:
					body.energy._drain_charge(drain_amount, true)
				else:
					body.energy._drain_charge(drain_amount, false)
