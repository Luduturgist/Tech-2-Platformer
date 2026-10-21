extends Attack_Lever

@export var pain_area: Area2D
@export var amplitude: float = 0.35
@export var speed: float = 4

var original_alpha: float
var time: float

func _ready():
	super._ready()
	original_alpha = pain_area.modulate.a
	flipped.connect(disable_pain_node)

func disable_pain_node(id: int):
	pain_area.enabled = false
	pain_area.visible = false

func _process(delta: float) -> void:
	time += delta
	
	var wave = sin(time * speed) * amplitude
	
	pain_area.modulate.a = original_alpha + wave
