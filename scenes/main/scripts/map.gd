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

var river_width  : int
var river_start_x: int

var map_size_x
var map_size_y

func generate_map(visible_rect_global: Rect2) -> void:
	var map_size = visible_rect_global.size
	var tile_size = tile_set.tile_size
	self.map_size_x = ceil(float(map_size.x) / (tile_size.x * scale.x))
	self.map_size_y = ceil(float(map_size.y) / (tile_size.y * scale.y))
	self.river_width = self.map_size_x / 2  # Initial width of the river
	self.river_start_x = (self.map_size_x - self.river_width) / 2  # Center river
	
	for y in range(map_size_y):
		add_new_row(y)

func update_tilemap_frustum(visible_rect_global: Rect2) -> void:
	# the camera is restricted to move only vertically up
	# horizontal movement and vertical down movement is not allowed
	if is_top_of_map_empty(visible_rect_global):
		add_new_row(get_map_top_row_index())
		
	if is_bottom_row_of_map_invisible(visible_rect_global):
		erase_bottom_row()

func get_map_bottom_row_index() -> int:
	# initiallly bottom row index is -1, top row index is -15
	return get_used_rect().position.y + get_used_rect().size.y + INITIAL_MAP_BOTTOM_INDEX

func get_map_top_row_index() -> int:
	return get_used_rect().position.y + INITIAL_MAP_BOTTOM_INDEX

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
	var row_count = abs(get_used_rect().position.y)
	var total_tiles_height = row_count * scaled_tile_height
	var map_top_coordinate = global_position.y - total_tiles_height
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

func add_new_row(y_index: int) -> void:
	var river_expanded_left : bool = false
	var river_narrowed_right: bool = false
	var river_width_next    : int  = river_width
	var river_start_x_next  : int  = river_start_x
	
	for x in range(map_size_x):
		var tile = LAND
			
		# Determine if the tile is part of the river or land
		if x >= river_start_x and x < river_start_x + river_width:
			if randi_range(0, 10) < 2:  # Small chance for islands in the river
				tile = Vector2i(0, 0)  # Ground tile (island)
			else:
				tile = Vector2i(1, 0)  # River tile
		else:
			tile = LAND
			
		# Add continuity by adjusting the river width
		if x == river_start_x - 1 and randi_range(0, 5) == 0:  # Left edge of the river
				tile = RIVER_EXPAND_LEFT
				river_expanded_left = true
				river_start_x_next = river_start_x_next - 1
				river_width_next = river_width_next + 1
		elif x == river_start_x and randi_range(0, 5) == 0 and not river_expanded_left:  # Narrowing river on the left
			tile = RIVER_NARROW_LEFT
			river_start_x_next = river_start_x_next + 1
			river_width_next = river_width_next - 1
		elif x == river_start_x + river_width - 1 and randi_range(0, 5) == 0:  # Narrowing river on the right
			tile =RIVER_NARROW_RIGHT
			river_narrowed_right = true
			river_width_next = river_width_next - 1
		elif x == river_start_x + river_width and randi_range(0, 5) == 0 and not river_narrowed_right:  # Right edge of the river
				tile = RIVER_EXPAND_RIGHT
				river_width_next = river_width_next + 1
		set_cell(Vector2i(x, y_index), RIVER_RAID_ATLAS_ID, tile, 0)
	
	self.river_start_x = river_start_x_next
	self.river_width = river_width_next

func erase_bottom_row() -> void:
	var map_size_x = get_used_rect().size.x
	var y_index = get_map_bottom_row_index()
	const source_id_of_erase = -1
	
	# erase bottom row only if TileMapLayer is non-empty
	if map_size_x > 0:
		# erase all the cells in the row
		for x_index in range(map_size_x):
			set_cell(Vector2i(x_index, y_index), source_id_of_erase)
