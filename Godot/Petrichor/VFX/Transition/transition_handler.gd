extends CanvasLayer

@export var loading_screen: Control
@export var close_time: float = 0.3
@export var open_time: float = 0.1

signal scene_closed
signal scene_opened

var fade_direction: int = 0

func _close_scene() -> Signal:
	loading_screen.modulate.a = 0
	fade_direction = 1
	loading_screen.visible = true
	return scene_closed

func _open_scene() -> Signal:
	fade_direction = -1
	loading_screen.modulate.a = 1
	return scene_opened

var fade: float = 0
func _process(delta: float):
	if fade_direction != 0:
		fade += fade_direction * delta / close_time
		update_fade_values()
		
		if fade_direction == 1 and loading_screen.modulate.a >= 1:
			fade = 1
			update_fade_values()
			await RenderingServer.frame_post_draw
			scene_closed.emit()
		
		if fade_direction == -1 and loading_screen.modulate.a <= 0:
			fade = 0
			update_fade_values()
			loading_screen.visible = false
			await RenderingServer.frame_post_draw
			scene_opened.emit()

func update_fade_values():
	loading_screen.modulate.a = fade
	AudioHandler.set_fade(1 - fade)
