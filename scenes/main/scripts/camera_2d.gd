extends Camera2D

func get_camera_bottom_world_y_coordinate() -> float:
	var camera_global_position = global_position
	var camera_viewport_height = get_viewport().get_visible_rect().size.y
	var camera_bottom_visible_coordinate = camera_global_position.y + (camera_viewport_height / 2)
	#if print_messages : print("camera_bottom_visible_coordinate: %d" % camera_bottom_visible_coordinate)
	return camera_bottom_visible_coordinate
