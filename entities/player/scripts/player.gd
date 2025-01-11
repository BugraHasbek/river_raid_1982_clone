extends Area2D

const player_horizontal_speed : int = 800 # pixel per second

func _process(delta: float) -> void:
	handle_movement(delta)
	
func handle_movement(delta: float) -> void:
	if Input.is_action_pressed("left"):
		position.x -= delta * player_horizontal_speed
	elif Input.is_action_pressed("right"):
		position.x += delta * player_horizontal_speed
