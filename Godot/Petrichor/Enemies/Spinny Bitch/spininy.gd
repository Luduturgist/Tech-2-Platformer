extends EnemyAttackBehavior
class_name Kamikaze

@export var damage_path: NodePath
var damager: Damage_Area

func _start(e: Enemy):
	super._start(e)
	enemy.set_meta("Mortal", false)
	damager = enemy.get_node(damage_path)
	enemy.stunned.connect(vulnerable_stun)

	if enemy.is_multiplayer_authority():
		damager.damage_blocked.connect(trigger_stun)
		damager.impact.connect(enemy.knockback_enemy)
	

func _attack_start():
	pass

func _attack_end():
	pass

func trigger_stun(pos: float):
	enemy.rpc("_network_stun", pos)

func vulnerable_stun():
	enemy.set_meta("Mortal", true)
	damager.enabled = false
	while enemy.stun_timer > 0:
		await enemy.get_tree().process_frame
	enemy.set_meta("Mortal", false)
	damager.enabled = true
