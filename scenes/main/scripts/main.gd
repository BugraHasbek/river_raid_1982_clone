extends Node2D

@onready var map: TileMapLayer = $Map

func _ready() -> void:
	randomize()
	map.generate_map()
