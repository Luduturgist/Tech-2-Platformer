extends Node2D

@export var parent: Enemy
@export var flash_duration: float = 0.15
@export var event: event_type

enum event_type {
	Damaged,
	Fertilized
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	match event:
		event_type.Damaged:
			parent.damage_taken.connect(_flash)
		event_type.Fertilized:
			parent.fertilized.connect(_flash)

func _flash():
	flash_timer = flash_duration
	material.set_shader_parameter("flash_modifier", 0.8)

var flash_timer: float
func _process(delta: float) -> void:
	if flash_timer > 0:
		flash_timer -= delta
		if flash_timer <= 0:
			flash_timer = 0
			material.set_shader_parameter("flash_modifier", 0)
