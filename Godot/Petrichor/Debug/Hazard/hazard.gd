extends Area2D

@export var damage: int = 1

func _ready():
	body_entered.connect(damage_player)

func damage_player(body):
	if body is not PlayerMovement or not body.local: return
	body._take_damage(damage)
