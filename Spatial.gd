extends Spatial


var _player_instances_by_id: Dictionary = {}


func _ready() -> void:
	Lobby.world = self


remotesync func create_player_instance(id: int) -> void:
	var instance: KinematicBody = load("res://KinematicBody.tscn").instance()
	add_child(instance)
	instance.configure_and_activate({"peer_id": id, "world" : self})
	
	_player_instances_by_id[id] = instance


	# We must bounce the data through a known node, else the path wont match between clients
remote func send_sync_data_to(id: int, data: Dictionary) -> void:
	_player_instances_by_id[id]._set_sync_data(data)
