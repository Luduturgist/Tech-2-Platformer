extends MultiplayerSynchronizer

func _ready() -> void:
	Wrapper.begin_desync.connect(_desync_turret)

func _desync_turret():
	replication_config = null
