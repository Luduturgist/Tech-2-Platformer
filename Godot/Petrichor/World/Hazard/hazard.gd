extends Area2D

func _ready():
	body_entered.connect(damage_player)

func damage_player(body):
	if body is not Movement or not body.sp: return
	body._take_damage()
