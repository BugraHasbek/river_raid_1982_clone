extends Area2D

const IS_DEBUG_MODE     : bool  = false
const MAX_SPEED         : float = 1200.0 #pixel per second
const DEFAULT_SPEED     : float = 400.0  #pixel per second
const MIN_SPEED         : float = 100.0  #pixel per second
const ACCELERATION_RATE : float = 300.0  # pixed per second
const DECELERATION_RATE : float = 100.0  # pixed per second
const HORIZONTAL_SPEED  : float = 800    # pixel per second

var   vertical_speed    : float = DEFAULT_SPEED

@onready var camera_2d  : MovingCamera = $Camera2D
@onready var speed_label: Label        = $speed
@onready var map_size   : Label        = $map_size
@onready var map        : TileMapLayer = $"../Map"


func _process(delta: float) -> void:
	var horizontal_displacement:float = 0.0
	
	if IS_DEBUG_MODE:
		horizontal_displacement = debug_move_player(delta)
	else:
		horizontal_displacement = move_player(delta)
	
	update_camera_horizontal_position(horizontal_displacement)
	update_ui()


## Moves the player horizontally and vertically (always moves upward) based on player input.
## Also updates speed-related UI elements.
## 
## Args:
## delta (float): The time elapsed since the last frame.
## 
## Returns:
## float: The horizontal displacement amount.
func move_player(delta: float) -> float:
	var horizontal_displacement:float  = 0.0
	
	# move left or right
	if Input.is_action_pressed("left"):
		horizontal_displacement = delta * HORIZONTAL_SPEED * -1.0
		position.x += horizontal_displacement
	elif Input.is_action_pressed("right"):
		horizontal_displacement = delta * HORIZONTAL_SPEED
		position.x += horizontal_displacement

	# make sure speed is between min & max limits while accelerating/decelerating
	if Input.is_action_pressed("accelerate"):
		vertical_speed = clamp(vertical_speed + (ACCELERATION_RATE * delta), MIN_SPEED, MAX_SPEED)
	elif Input.is_action_pressed("decelerate"):
		vertical_speed = clamp(vertical_speed - (DECELERATION_RATE * delta), MIN_SPEED, MAX_SPEED)
	else:
		# Not realistic to go from top speed to default speed directly
		# but seems like a better mechanic
		# TODO: experiment later for best way to do it
		vertical_speed = DEFAULT_SPEED
		
	# accelarate/decelarate changes vertical speed but the plane always move forward
	position.y -= delta * vertical_speed
	
	return horizontal_displacement

# move player horizontally and vertically (both up and down) according to player input
# update speed related UI elements 
# return horizontal displacement amount
func debug_move_player(delta: float) -> float:
	var horizontal_displacement:float  = 0.0
	
	# move left or right
	if Input.is_action_pressed("left"):
		horizontal_displacement = delta * HORIZONTAL_SPEED
		position.x -= horizontal_displacement
	elif Input.is_action_pressed("right"):
		horizontal_displacement = delta * HORIZONTAL_SPEED
		position.x += horizontal_displacement

	# move up or down
	if Input.is_action_pressed("accelerate"):
		position.y -= delta * vertical_speed
	elif Input.is_action_pressed("decelerate"):
		position.y += delta * vertical_speed
	
	return horizontal_displacement


# camera moves with the player both vertically and horizontally 
# because it is Player's child
# however camera should not move horizontally when player moves horizontally
# move camera position in the reverse direction when player moves horizontally
# so that camera is locked to the same position horizontally
func update_camera_horizontal_position(horizontal_displacement: float) -> void:
	camera_2d.position.x   -= horizontal_displacement
	speed_label.position.x -= horizontal_displacement
	map_size.position.x    -= horizontal_displacement


# update UI elements
func update_ui() -> void:
	var size = map.get_used_rect().size
	map_size.text = "Map size: [%d, %d = %d]" % [size.x, size.y, size.x * size.y]
	speed_label.text = "Speed: %d" % vertical_speed
	
