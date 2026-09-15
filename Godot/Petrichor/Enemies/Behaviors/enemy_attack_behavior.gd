@abstract
extends Resource
class_name EnemyAttackBehavior

@export var damage: int = 1
@export var attack_delay: float = 0.5
@export var attack_duration: float = 1
@export var attack_interval: float = 0.5
var enemy: Enemy

var windup: float
var attack_timer: float

@abstract func _attack_start()

@abstract func _attack_end()

func _start(e: Enemy):
	enemy = e

func _update(_delta: float):
	pass

func is_attacking() -> bool:
	return (not attack_timer == 0 or not windup == 0)
