extends TileMapLayer

const river_raid_atlas_id = 0

func _ready() -> void:
	randomize()
	generate_map()

func generate_map() -> void:
	var map_size = get_used_rect().size  # Get the size of the map
	for x in range(map_size.x):
		for y in range(map_size.y):
			var random_tile_x = randi_range(0, 3)
			var random_tile_y = randi_range(0, 1)
			set_cell(Vector2i(x, y), river_raid_atlas_id, Vector2i(random_tile_x, random_tile_y), 0)  # Set the cell to the random tile
