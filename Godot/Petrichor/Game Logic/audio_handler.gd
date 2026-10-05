extends Node
class_name Audio_Handler

var music: AudioStreamPlayer
var ambience: AudioStreamPlayer

var muted: bool = false

enum PLAYER_SFX {
	SFX_PUSH,
	SFX_JUMP,
	SFX_RUN
}

func _ready() -> void:
	music =  AudioStreamPlayer.new()
	ambience =  AudioStreamPlayer.new()

func set_fade(fade: float):
	if muted:
		return
	
	if fade > 0:
		AudioServer.set_bus_mute(0, false)
	else:
		AudioServer.set_bus_mute(0, true)
		return
	
	AudioServer.set_bus_volume_linear(0, fade)

func _mute(value: bool = true):
	AudioServer.set_bus_mute(0, value)
	muted = value
