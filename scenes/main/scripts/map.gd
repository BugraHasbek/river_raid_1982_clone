extends TileMapLayer

const RIVER_RAID_ATLAS_ID = 0
const INITIAL_MAP_BOTTOM_INDEX = -1

@onready var camera_2d: Camera2D = $"../Player/Camera2D"

var process_duration: float = 0.0
var print_messages: bool = true

func _process(delta: float) -> void:
	if process_duration >= 0:
		print_messages = true
		process_duration -= 0.5
	else:
		print_messages = false
	process_duration += delta
		
	update_tilemap_frustum()

# This function assumes that initially Camera2D and TileMapLayer will be on top of each other 
func generate_map() -> void:
	var visible_map_size = camera_2d.get_viewport().get_visible_rect().size
	var tile_size = tile_set.tile_size
	
	# make sure floating point division is done and the result is always rounded up, so that map will always fill the whole screen
	var map_size_x = ceil(float(visible_map_size.x) / (tile_size.x * scale.x))
	var map_size_y = ceil(float(visible_map_size.y) / (tile_size.y * scale.y))
	print("Generating a map with size: [%d,%d]" % [map_size_x, map_size_y])
	for x in range(map_size_x):
		for y in range(map_size_y):
			var random_tile_x = randi_range(0, 3)
			var random_tile_y = randi_range(0, 1)
			
			# TileMapLayer is anchored to the left bottom of screen
			# So tile [0, 0] would be below the screen. However we want the tileset to grow up, so we need to start filling the tilemap starting from 0, -1
			set_cell(Vector2i(x, -y - 1), RIVER_RAID_ATLAS_ID, Vector2i(random_tile_x, random_tile_y), 0)  # Set the cell to the random tile
			#print("Filling %d,%d" % [x, -y -1])

func update_tilemap_frustum() -> void:
	# the camera is restricted so it only moves vertically up
	#if is_top_of_map_empty():
		#add_new_row()
		
	if is_bottom_row_of_map_invisible():
		erase_bottom_row()

func is_top_of_map_empty() -> bool:
	var camera_global_position = camera_2d.global_position
	var camera_viewport_height = camera_2d.get_viewport().get_visible_rect().size.y
	var top_visible_coordinate = camera_global_position.y - (camera_viewport_height / 2)
	#print("top_visible_coordinate: %d" % top_visible_coordinate)
	
	var tile_size = tile_set.tile_size
	var used_rect_size = get_used_rect().size  # Rect containing all used tiles
	var total_height = used_rect_size.y * tile_size.y * scale.y  # Total height of the tilemap in pixels
	var map_top_coordinate = global_position.y - total_height
	#print("map_top_coordinate: %d" % map_top_coordinate)
	
	return  top_visible_coordinate < map_top_coordinate

# The bottom-most row index in tile coordinates
func get_map_bottom_index() -> int:
	# initiallly bottom row is -1, top row is -15
	return get_used_rect().position.y + get_used_rect().size.y + INITIAL_MAP_BOTTOM_INDEX

# calculate the world position.y of the bottom row of TileMapLayer which may or may not be visible
func get_map_bottom_row_world_y_coordinate() -> float:
	# Take scaling into account
	var tile_size = tile_set.tile_size * scale.y  
	
	# initial bottom index is -1, so if current map bottom index is -4: 
	# then 3 rows(-1, -2 and -3) have been deleted
	var deleted_tile_count = INITIAL_MAP_BOTTOM_INDEX - get_map_bottom_index()
	var deleted_tiles_height = deleted_tile_count * tile_size.y
	var map_bottom_coordinate = global_position.y - deleted_tiles_height
	#if print_messages : print("deleted_tile_count: %d, map_bottom_coordinate: %d" % [deleted_tile_count, map_bottom_coordinate])
	return map_bottom_coordinate



func get_camera_top_world_y_coordinate() -> float:
	var camera_global_position = camera_2d.global_position
	var camera_viewport_height = camera_2d.get_viewport().get_visible_rect().size.y
	var camera_bottom_visible_coordinate = camera_global_position.y + (camera_viewport_height / 2)
	#if print_messages : print("camera_bottom_visible_coordinate: %d" % camera_bottom_visible_coordinate)
	return camera_bottom_visible_coordinate

func is_bottom_row_of_map_invisible() -> bool:
	# to be fully invisible the whole tile must be under the camera viewport
	var map_bottom_row_top_y_coordinate = get_map_bottom_row_world_y_coordinate() - tile_set.tile_size.y * scale.y
	return map_bottom_row_top_y_coordinate > camera_2d.get_camera_bottom_world_y_coordinate()

# Add a new row of random tiles at the top of the map
func add_new_row() -> void:
	var map_size = get_used_rect().size
	for x in range(map_size.x):
		var random_tile_x = randi_range(0, 3)
		var random_tile_y = randi_range(0, 1)
		# TODO: make "-map_size.y - 1" more readable
		set_cell(Vector2i(x, -map_size.y - 1), RIVER_RAID_ATLAS_ID, Vector2i(random_tile_x, random_tile_y), 0)

func erase_bottom_row() -> void:
	var map_size_x = get_used_rect().size.x
	var y_index = get_map_bottom_index()
	const source_id_of_erase = -1
	
	# erase bottom row only if TileMapLayer is non-empty
	if map_size_x > 0:
		# erase all the cells in the row
		for x_index in range(map_size_x):
			set_cell(Vector2i(x_index, y_index), source_id_of_erase)
