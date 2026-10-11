extends Node2D
class_name Hold_Interact

@export var detection_area: Area_Detector
@export var enabled: bool = false
@export var redlight: Node2D

var pressed: bool = false
var exhausted: bool = false
var detected_players: Array[PlayerMovement]
var interacting_player: PlayerMovement


func _ready():
	detection_area.target_found.connect(track)
	detection_area.target_lost.connect(track)

func track():
	var targets: Array = detection_area.targets
	
	for i in targets.size():
		if detected_players.find(targets[i]) < 0:
			detected_players.append(targets[i])
			targets[i].special_interact.connect(activate)
	
	for i in detected_players.size():
		if targets.find(detected_players[i]) < 0:
			if interacting_player == detected_players[i]:
				interacting_player.interact_end.emit()
			detected_players[i].special_interact.disconnect(activate)
			detected_players.remove_at(i)

func activate():
	if pressed or not enabled:
		return
	
	interacting_player = Game_Scene.active.local
	
	rpc("button_interact", true)
	
	await Game_Scene.active.local.interact_end
	
	interacting_player = null
	
	if pressed:
		rpc("button_interact", false)
		pressed = false

func _exhaust():
	rpc("exhaust_button")

@rpc("any_peer", "call_local", "reliable")
func button_interact(value: bool):
	pressed = value
	redlight.visible = not value

@rpc("any_peer", "call_local", "reliable")
func exhaust_button():
	enabled = false
	redlight.color = Color.GREEN
	redlight.visible = true
	for p in detected_players:
		p.special_interact.disconnect(activate)
	detected_players.clear()
