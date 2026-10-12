extends Node
class_name PlayerGUI

@export var game_scene: Game_Scene

@export var energyBar: TextureProgressBar
@export var pain_bar: TextureProgressBar
@export var bar_flash: TextureRect
@export var frame_flash: TextureRect
@export var bar_flash_time: float = 0.15
@export var bar_flash_interval: float = 0.075
@export var bar_flash_saturation: float = 0.8
@export var frame_flash_saturation = 0.6

var energy: PlayerEnergy

func _ready() -> void:
	await game_scene.scene_ready
	await get_tree().process_frame
	
	energy = game_scene.local.energy
	energy.update_ui.connect(update_energy)
	energy.drained.connect(set_bar)
	energy.passive_drain_update.connect(set_frame)
	energyBar.max_value = energy.maxCharge
	pain_bar.max_value = energy.maxCharge
	set_shader_alpha(bar_flash, 0)
	set_shader_alpha(frame_flash, 0)
	
	update_energy(energy.charge, energy.pain)

var bar_timer: float
var frame_buffer: float
func _process(delta: float) -> void:
	if bar_timer < 0:
		bar_timer += delta
		if bar_timer >= 0:
			bar_timer = bar_flash_time - bar_timer
			set_shader_alpha(bar_flash, bar_flash_saturation)
	
	if bar_timer > 0:
		bar_timer -= delta
		if bar_timer <= 0:
			bar_timer = 0
			set_shader_alpha(bar_flash, 0)
	
	if frame_buffer > 0:
		frame_buffer -= delta
		if frame_buffer <= 0:
			set_shader_alpha(frame_flash, 0)
			frame_buffer = 0 

func update_energy(charge: int, pain: int):
	print(str(charge))
	energyBar.value = charge
	pain_bar.value = pain

func set_frame(value: bool):
	if value:
		set_shader_alpha(frame_flash, frame_flash_saturation)
		frame_buffer = 0
	else:
		frame_buffer = 0.15

func set_bar(amount: int):
	if bar_timer == 0:
		bar_timer = bar_flash_time * amount
		set_shader_alpha(bar_flash, bar_flash_saturation)
	else:
		bar_timer = -bar_flash_interval
		set_shader_alpha(bar_flash, 0)

func set_shader_alpha(n: Node, alpha: float):
	var new_color = n.material.get_shader_parameter("flash_color")
	new_color.a = alpha
	n.material.set_shader_parameter("flash_color", new_color)
