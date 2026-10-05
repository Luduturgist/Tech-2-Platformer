extends Grounded_Enemy

@export var tracking_feedback: Node2D
@export var damage_feedback: Node2D


func _ready() -> void:
	super._ready()
	update_tracking.connect(_show_tracking)
	damage_taken.connect(_show_damage)

func _show_death():
	damage_feedback.visible = true
	damage_vfx_timer = 0
	attack_feedback.visible = false
	super._show_death()

func _show_tracking(value: bool):
	tracking_feedback.visible = value

var damage_vfx_timer: float = 0
func _show_damage():
	if not damage_feedback.visible:
		damage_feedback.visible = true
		damage_vfx_timer = 0.5
	else:
		damage_vfx_timer = -0.1
		damage_feedback.visible = false

func _process(delta: float) -> void:
	super._process(delta)
	if damage_vfx_timer > 0:
		damage_vfx_timer -= delta
		if damage_vfx_timer <= 0:
			damage_vfx_timer = 0
			damage_feedback.visible = false
	elif damage_vfx_timer < 0:
		damage_vfx_timer += delta
		if damage_vfx_timer >= 0:
			damage_vfx_timer = 0.5
			damage_feedback.visible = true
