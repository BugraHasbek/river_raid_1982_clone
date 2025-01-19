extends Camera2D

class_name MovingCamera

func get_global_rect() -> Rect2:
	var viewport: Viewport = get_viewport()
	var global_to_viewport: Transform2D = viewport.global_canvas_transform * get_canvas_transform()
	var viewport_to_global: Transform2D = global_to_viewport.affine_inverse()
	
	var viewport_rect: Rect2 = get_viewport_rect()
	var global_rect: Rect2 = viewport_to_global * viewport_rect
	return global_rect
	
	
