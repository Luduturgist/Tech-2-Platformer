@abstract
extends Resource
class_name EnemyAttackBehavior

@export var attack_delay: float = 0.2
@export var attack_duration: float = 0.2
@export var attack_interval: float = 0.2
@export var lunge: Vector2

var windup: float
var attack_timer: float
var cooldown_timer: float
var already_hit: bool = false

var enemy: Enemy

@abstract func _attack_start()

@abstract func _attack_end()

func _start(e: Enemy):
	enemy = e

func _update(_delta: float):
	pass

func is_attacking() -> bool:
	return (attack_timer != 0 or windup != 0 and cooldown_timer == 0)

func can_attack() -> bool:
	return (attack_timer == 0 and windup == 0 and cooldown_timer == 0)

func _damage_player(player: PlayerMovement):
	if enemy.damage:
		player._take_damage(enemy.damage, enemy.attack_source.global_position.x)
	if enemy.drain:
		player.energy._drain_charge(enemy.drain)
	already_hit = true
