extends Label
@onready var player: Area2D = $".."

func _process(delta: float) -> void:
	var speed = player.player_vertical_speed
	self.text = "Speed: %d" % speed
