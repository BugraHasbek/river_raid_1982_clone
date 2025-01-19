extends Label

@onready var map: TileMapLayer = $"../../Map"

func _process(delta: float) -> void:
	var size = map.get_used_rect().size
	self.text = "Map size: [%d, %d = %d]" % [size.x, size.y, size.x * size.y]
	pass
