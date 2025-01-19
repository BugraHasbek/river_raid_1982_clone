extends TileMapLayer

const RIVER_RAID_ATLAS_ID = 0
const INITIAL_MAP_BOTTOM_INDEX = -1

func generate_map(visible_rect_global: Rect2) -> void:
	var map_size = visible_rect_global.size
	var tile_size = tile_set.tile_size
	
	# make sure floating point division is done and the result is always rounded up, so that map will always fill the whole screen
	# TODO: use position of area to remove dependency to assumption that TileMapLayer and Camera2D are on top of each other
	var map_size_x = ceil(float(map_size.x) / (tile_size.x * scale.x))
	var map_size_y = ceil(float(map_size.y) / (tile_size.y * scale.y))
	print("Generating a map with size: [%d,%d]" % [map_size_x, map_size_y])
	for x in range(map_size_x):
		for y in range(map_size_y):
			var random_tile_x = randi_range(0, 3)
			var random_tile_y = randi_range(0, 1)
			
			# TileMapLayer is anchored to the left bottom of screen
			# So tile [0, 0] would be below the screen. However we want the tileset to grow up, so we need to start filling the tilemap starting from 0, -1
			set_cell(Vector2i(x, -y - 1), RIVER_RAID_ATLAS_ID, Vector2i(random_tile_x, random_tile_y), 0)  # Set the cell to the random tile
			#print("Filling %d,%d" % [x, -y -1])

func update_tilemap_frustum(visible_rect_global: Rect2) -> void:
	# the camera is restricted so it only moves vertically up
	if is_top_of_map_empty(visible_rect_global):
		add_new_row_to_top()
		
	if is_bottom_row_of_map_invisible(visible_rect_global):
		erase_bottom_row()

func get_map_bottom_row_index() -> int:
	# initiallly bottom row is -1, top row is -15
	return get_used_rect().position.y + get_used_rect().size.y + INITIAL_MAP_BOTTOM_INDEX

func get_map_bottom_row_world_y_coordinate() -> float:
	var scaled_tile_height = tile_set.tile_size.y * scale.y  
	
	# initial bottom index is -1, so if current map bottom index is -4: 
	# then 3 rows (-1, -2 and -3) have been deleted
	var deleted_tile_count = INITIAL_MAP_BOTTOM_INDEX - get_map_bottom_row_index()
	var deleted_tiles_height = deleted_tile_count * scaled_tile_height
	var map_bottom_coordinate = global_position.y - deleted_tiles_height
	return map_bottom_coordinate
	
func get_map_top_row_world_y_coordinate() -> float:
	var scaled_tile_height = tile_set.tile_size.y * scale.y  
	var tile_count = abs(get_used_rect().position.y)
	var all_tiles_height = tile_count * scaled_tile_height
	var map_top_coordinate = global_position.y - all_tiles_height
	return map_top_coordinate

func is_top_of_map_empty(visible_rect_global: Rect2) -> bool:
	var camera_top_y_coordinate = visible_rect_global.position.y
	var map_top_row_top_y_coordinate = get_map_top_row_world_y_coordinate()
	return  map_top_row_top_y_coordinate > camera_top_y_coordinate

func is_bottom_row_of_map_invisible(visible_rect_global: Rect2) -> bool:
	# to be fully invisible the whole tile must be under the camera viewport
	var map_bottom_row_top_y_coordinate = get_map_bottom_row_world_y_coordinate() - tile_set.tile_size.y * scale.y
	var camera_bottom_y_coordinate = visible_rect_global.position.y + visible_rect_global.size.y
	return map_bottom_row_top_y_coordinate > camera_bottom_y_coordinate

func add_new_row_to_top() -> void:
	var map_size = get_used_rect().size
	var new_y_index = get_used_rect().position.y - 1
	print("Adding new row at index: %d" % new_y_index)
	for x in range(map_size.x):
		var random_tile_x = randi_range(0, 3)
		var random_tile_y = randi_range(0, 1)
		set_cell(Vector2i(x, new_y_index), RIVER_RAID_ATLAS_ID, Vector2i(random_tile_x, random_tile_y), 0)

func erase_bottom_row() -> void:
	var map_size_x = get_used_rect().size.x
	var y_index = get_map_bottom_row_index()
	const source_id_of_erase = -1
	
	# erase bottom row only if TileMapLayer is non-empty
	if map_size_x > 0:
		# erase all the cells in the row
		for x_index in range(map_size_x):
			set_cell(Vector2i(x_index, y_index), source_id_of_erase)
