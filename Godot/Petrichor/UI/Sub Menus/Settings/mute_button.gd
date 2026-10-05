extends Button


func _ready() -> void:
	button_pressed = AudioHandler.muted
	toggle_mode = true

func _toggled(toggled_on: bool) -> void:
	AudioHandler._mute(toggled_on)
