extends TileMapLayer

const RIVER_RAID_ATLAS_ID = 0
const INITIAL_MAP_BOTTOM_INDEX = -1

const LAND              : Vector2 = Vector2(0, 0)
const RIVER             : Vector2 = Vector2(1, 0)
const HOUSE             : Vector2 = Vector2(2, 0)
const RIVER_NARROW_LEFT : Vector2 = Vector2(3, 0)
const ROAD              : Vector2 = Vector2(0, 1)
const RIVER_NARROW_RIGHT: Vector2 = Vector2(1, 1)
const RIVER_EXPAND_LEFT : Vector2 = Vector2(2, 1)
const RIVER_EXPAND_RIGHT: Vector2 = Vector2(3, 1)

var river_width: int
var river_start_x: int

func generate_map(visible_rect_global: Rect2) -> void:
	var map_size = visible_rect_global.size
	var tile_size = tile_set.tile_size
	
	var map_size_x = ceil(float(map_size.x) / (tile_size.x * scale.x))
	var map_size_y = ceil(float(map_size.y) / (tile_size.y * scale.y))
	
	river_width = map_size_x / 2  # Initial width of the river
	river_start_x = (map_size_x - river_width) / 2  # Center river
	
	var river_width_next: int = river_width
	var river_start_x_next: int = river_start_x
	
	var river_expanded_left = false
	var river_narrowed_right = false
	
	for y in range(map_size_y):
		for x in range(map_size_x):
			var tile = LAND
			
			# Determine if the tile is part of the river or land
			if x >= river_start_x and x < river_start_x + river_width:
				## remove below line to allow generation of islands
				tile = RIVER
				#if randi_range(0, 10) < 2:  # Small chance for islands in the river
					#tile = Vector2i(0, 0)  # Ground tile (island)
				#else:
					#tile = Vector2i(1, 0)  # River tile
				print("River: x:%d, y:%d" % [x, y])
			else:
				print("Land: x:%d, y:%d" % [x, y])
				tile = LAND
				
			# Add continuity by adjusting the river width
			if x == river_start_x - 1 and randi_range(0, 5) > 3:  # Left edge of the river
					tile = RIVER_EXPAND_LEFT
					river_expanded_left = true
					river_start_x_next = river_start_x_next - 1
					river_width_next = river_width_next + 1
					print("Expanding river left. x: %d, y:%d, river_start_x: %d, river_start_x_next: %d" % [x,y, river_start_x, river_start_x_next])
			elif x == river_start_x and randi_range(0, 5) > 3 and not river_expanded_left:  # Narrowing river on the left
				print("Narrowing river left")
				tile = RIVER_NARROW_LEFT
				river_start_x_next = river_start_x_next + 1
				river_width_next = river_width_next - 1
			elif x == river_start_x + river_width - 1 and randi_range(0, 5) > 3:  # Narrowing river on the right
				print("Narrowing river right")
				tile =RIVER_NARROW_RIGHT
				river_narrowed_right = true
				river_width_next = river_width_next - 1
			elif x == river_start_x + river_width and randi_range(0, 5) > 3 and not river_narrowed_right:  # Right edge of the river
					print("Expanding river right")
					tile = RIVER_EXPAND_RIGHT
					river_width_next = river_width_next + 1
			set_cell(Vector2i(x, -y - 1), RIVER_RAID_ATLAS_ID, tile, 0)
		
		river_start_x = river_start_x_next
		river_width = river_width_next
		river_expanded_left = false
		river_narrowed_right = false

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
