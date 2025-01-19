extends Node2D

@onready var map: TileMapLayer = $Map
@onready var camera_2d: MovingCamera = $Player/Camera2D

func _ready() -> void:
	randomize()
	map.generate_map(camera_2d.get_global_rect())

func _process(delta: float) -> void:
	map.update_tilemap_frustum(camera_2d.get_global_rect())
