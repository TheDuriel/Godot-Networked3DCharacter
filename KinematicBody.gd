extends KinematicBody
"""
	Client Authorative 3rd Person Kinematic Character Controller
"""

export(float, 0.0, 40.0) var MOVEMENT_SPEED: float = 10.0 # Meters per Second
export(float, 0.0, 40.0) var GRAVITY: float = 1.62  # Meters per Second
export(float, 0.0, 40.0) var TERMINAL_VELOCITY: float = 22.0
export(float, 0.0, 1.0) var DECELERATION_RATE: float = 0.05 # % Of speed lost per Frame
export(float, 0.0, 40.0) var JUMP_FORCE: float = 5.0
export(float, 0.0, 1.0) var REMOTE_INTERPOLATION_RATE: float = 0.5 # % Per Frame

onready var _collision_shape: CollisionShape = $"CollisionShape"
onready var _camera: Camera = $"Camera"

var _is_origin: bool = false
var _velocity: Vector3 = Vector3()

var _world: Spatial
var _peer_id: int
var _remote_target_transform: Transform = transform


	# We must wait for the remotepeer ID to be provided.
func _ready() -> void:
	set_physics_process(false)
	_collision_shape.disabled = true


func _physics_process(delta: float) -> void:
	if _is_origin:
		_origin_physics_process(delta)
	else:
		_remote_physics_process(delta)


func configure_and_activate(config_data: Dictionary) -> void:
	# Must receive: the PeerID which it represents
	if config_data.peer_id == get_tree().get_network_unique_id():
		_is_origin = true
		_collision_shape.disabled = false
		_camera.current = true
	
	# Any other data specific to that user
	# Like name, appearance, etc.
	
	_world = config_data.world
	_peer_id = config_data.peer_id
	set_physics_process(true)
	
	printt(config_data.peer_id, get_tree().get_network_unique_id())


	# Run on the Controlling Client
func _origin_physics_process(delta: float) -> void:
	
	# Input
	var input_direction: Vector3 = Vector3()
	
	if Input.is_action_pressed("ui_up"): # replace with real action
		input_direction += Vector3.FORWARD
	if Input.is_action_pressed("ui_down"): # replace with real action
		input_direction += Vector3.BACK
	if Input.is_action_pressed("ui_left"): # replace with real action
		input_direction += Vector3.LEFT
	if Input.is_action_pressed("ui_right"): # replace with real action
		input_direction += Vector3.RIGHT
	
	input_direction = input_direction.normalized()
	
	# Calculate Velocity
	_velocity += input_direction * MOVEMENT_SPEED * delta
	_velocity += Vector3.DOWN * GRAVITY * delta
	
	# Move
	
	_velocity = move_and_slide(_velocity, Vector3.UP)
	
	# Apply Jump Force
	
	if Input.is_action_pressed("ui_accept") and is_on_floor(): # replace with real action
		_velocity += Vector3.UP * JUMP_FORCE
	
	# Terminal Velocity and Deceleration
	
	if input_direction == Vector3():
		_velocity.x = lerp(_velocity.x, 0.0, DECELERATION_RATE)
		_velocity.z = lerp(_velocity.z, 0.0, DECELERATION_RATE)
	
	_velocity.y = clamp(_velocity.y, -TERMINAL_VELOCITY, TERMINAL_VELOCITY)
	
	# Control Animation Tree
	
	# Snych with Server
	
	var send_data: Dictionary = {}
	send_data.transform = transform
	
	# We must bounce the data through a known node, else the path wont match between clients
	_world.rpc("send_sync_data_to", _peer_id, send_data)


	# Run on Server and Remote Clients
func _remote_physics_process(delta: float) -> void:
	transform = transform.interpolate_with(_remote_target_transform, REMOTE_INTERPOLATION_RATE)


func _set_sync_data(data: Dictionary) -> void:
	_remote_target_transform = data.transform
