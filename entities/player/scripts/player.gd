extends Area2D

@export var MAX_SPEED: float = 1200.0 #pixel per second
@export var DEFAULT_SPEED: float = 400.0 #pixel per second
@export var MIN_SPEED: float = 100.0 #pixel per second
@export var ACCELERATION_RATE: float = 300.0 # pixed per second
@export var DECELERATION_RATE: float = 100.0 # pixed per second

const IS_DEBUG_MODE = false

const player_horizontal_speed : float = 800 # pixel per second
var player_vertical_speed : float = DEFAULT_SPEED

func _process(delta: float) -> void:
	if IS_DEBUG_MODE:
		debug_handle_movement(delta)
	else:
		handle_movement(delta)
	
func handle_movement(delta: float) -> void:
	# move left or right
	# TODO: currently camera moves left, right as well which is not intended
	# fix the bug in camera script so that camera x position is constant
	if Input.is_action_pressed("left"):
		position.x -= delta * player_horizontal_speed
	elif Input.is_action_pressed("right"):
		position.x += delta * player_horizontal_speed

	# make sure speed is between min & max limits while accelerating/decelerating
	if Input.is_action_pressed("accelerate"):
		player_vertical_speed = clamp(player_vertical_speed + (ACCELERATION_RATE * delta), MIN_SPEED, MAX_SPEED)
	elif Input.is_action_pressed("decelerate"):
		player_vertical_speed = clamp(player_vertical_speed - (DECELERATION_RATE * delta), MIN_SPEED, MAX_SPEED)
	else:
		# Not realistic to go from top speed to default speed directly
		# but seems like a better mechanic
		# TODO: experiment later for best way to do it
		player_vertical_speed = DEFAULT_SPEED
		
	# accelarate/decelarate changes vertical speed but the plane always move forward
	position.y -= delta * player_vertical_speed
	
func debug_handle_movement(delta: float) -> void:
	# move left or right
	if Input.is_action_pressed("left"):
		position.x -= delta * player_horizontal_speed
	elif Input.is_action_pressed("right"):
		position.x += delta * player_horizontal_speed

	# move up or down
	if Input.is_action_pressed("accelerate"):
		position.y -= delta * player_vertical_speed
	elif Input.is_action_pressed("decelerate"):
		position.y += delta * player_vertical_speed
