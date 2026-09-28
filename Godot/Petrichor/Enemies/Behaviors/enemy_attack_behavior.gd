@abstract
extends Resource
class_name EnemyAttackBehavior

@export var damage: int = 1
@export var drain: int = 0
@export var attack_delay: float = 0.2
@export var attack_duration: float = 0.2
@export var attack_interval: float = 0.2
@export var lunge: Vector2


var windup: float
var attack_timer: float
var already_hit: bool = false

var enemy: Enemy

@abstract func _attack_start()

@abstract func _attack_end()

func _start(e: Enemy):
	enemy = e

func _update(_delta: float):
	pass

func is_attacking() -> bool:
	return (not attack_timer == 0 or not windup == 0)

func _damage_player(player: PlayerMovement):
	if damage:
		player._take_damage(damage)
	if drain:
		player.energy._drain_charge(drain)
	already_hit = true
