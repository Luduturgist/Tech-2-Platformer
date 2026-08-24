extends Node

@export var dress_on_start := true

func _ready() -> void:
	if dress_on_start:
		find_child("Player A").dress()
