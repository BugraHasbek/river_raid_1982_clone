extends TileMapLayer

const RIVER_RAID_ATLAS_ID = 0
const INITIAL_MAP_BOTTOM_INDEX = -1
const MIN_RIVER_WIDTH = 4
const EXPANSION_SIZE = 2

const LAND              : Vector2 = Vector2(0, 0)
const RIVER             : Vector2 = Vector2(1, 0)
const HOUSE             : Vector2 = Vector2(2, 0)
const RIVER_SHRINK_LEFT : Vector2 = Vector2(3, 0)
const ROAD              : Vector2 = Vector2(0, 1)
const RIVER_SHRINK_RIGHT: Vector2 = Vector2(1, 1)
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
		add_new_row(-y + INITIAL_MAP_BOTTOM_INDEX)

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
	var tile
	
	var is_expanding: bool = false
	var is_shrinking: bool = false
	
	var river_width_next = self.river_width
	var river_start_x_next = self.river_start_x
	# 15% chance to expand, 15% to shrink, 70% to stay the same
	if randi_range(1, 100) <= 15 and river_width >= MIN_RIVER_WIDTH + EXPANSION_SIZE:
		river_width_next -= EXPANSION_SIZE
		river_start_x_next += EXPANSION_SIZE / 2
		is_shrinking = true
	elif randi_range(1, 100) >= 85 and river_width <= map_size_x - (MIN_RIVER_WIDTH / 2) - EXPANSION_SIZE:
		river_width_next += EXPANSION_SIZE
		river_start_x_next -= EXPANSION_SIZE / 2
		is_expanding = true
	
	# let's assume river start x was 7 and river is expanding
	# in this case tile 7 should be river and tile 6 should be half river half land
	# This is the reason why river start x is updated *before* creating tile in previous river start position
	if is_expanding:
		self.river_start_x = river_start_x_next
		self.river_width = river_width_next

	for x in range(map_size_x):
		if x < river_start_x or x > river_start_x + river_width:
			tile = LAND
		elif x == river_start_x:
			if is_expanding:
				tile = RIVER_EXPAND_LEFT
				print("expanding left. X:%d" % x)
			elif is_shrinking:
				print("shrinking left. X:%d" % x)
				tile = RIVER_SHRINK_LEFT
			else:
				tile = RIVER
		elif x == river_start_x + river_width:
			if is_expanding:
				tile = RIVER_EXPAND_RIGHT
				print("expanding right. X:%d" % x)
			elif is_shrinking:
				tile = RIVER_SHRINK_RIGHT
				print("shrinking right. X:%d" % x)
			else:
				tile = RIVER
		else:
			tile = RIVER
		
		# Set the cell in the TileMapLayer
		set_cell(Vector2i(x, y_index), RIVER_RAID_ATLAS_ID, tile, 0)
	
	# let's assume river start x was 7 and river is shrinking
	# in this case tile 7 should be half river half land
	# This is the reason why river start x is updated *after* creating tile in previous river start position
	if is_shrinking:
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
