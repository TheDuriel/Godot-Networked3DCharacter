extends CanvasLayer


var world: Spatial


func _ready() -> void:
	var tree: SceneTree = get_tree()
	tree.connect("network_peer_connected", self, "_on_network_peer_connected")
#	tree.connect("network_peer_disconnected", self, "_server_player_disconnected")
#	tree.connect("connected_to_server", self, "_connected_ok")
#	tree.connect("connection_failed", self, "_connected_fail")
#	tree.connect("server_disconnected", self, "_server_disconnected")


func _on_Host_pressed() -> void:
	var peer: NetworkedMultiplayerENet = NetworkedMultiplayerENet.new()
	peer.create_server(2305, 10)
	get_tree().set_network_peer(peer)
	
	get_child(0).visible = false
	OS.set_window_title("server")


func _on_Connect_pressed() -> void:
	var peer: NetworkedMultiplayerENet = NetworkedMultiplayerENet.new()
	peer.create_client("127.0.0.1", 2305)
	get_tree().set_network_peer(peer)
	
	get_child(0).visible = false
	OS.set_window_title("client")


func _on_network_peer_connected(id: int) -> void:
	if get_tree().is_network_server():
		world.rpc("create_player_instance", id)
