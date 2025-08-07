class_name Camera2DComponent extends Camera2D

func _get_window_width() -> int:
	return ProjectSettings.get_setting("display/window/size/viewport_width")

func _get_window_height() -> int:
	return ProjectSettings.get_setting("display/window/size/viewport_height")

func scale_to_width(viewport_size: Vector2) -> void:
	var scale_factor := viewport_size.x / _get_window_width()
	zoom = Vector2(scale_factor, scale_factor)

func scale_to_height(viewport_size: Vector2) -> void:
	var scale_factor := viewport_size.y / _get_window_height()
	zoom = Vector2(scale_factor, scale_factor)

func scale_to_fit(viewport_size: Vector2) -> void:
	var scale_x := viewport_size.x / _get_window_width()
	var scale_y := viewport_size.y / _get_window_height()
	var scale_factor := min(scale_x, scale_y)
	zoom = Vector2(scale_factor, scale_factor)

func scale_to_fill(viewport_size: Vector2) -> void:
	var scale_x := viewport_size.x / _get_window_width()
	var scale_y := viewport_size.y / _get_window_height()
	var scale_factor := max(scale_x, scale_y)
	zoom = Vector2(scale_factor, scale_factor)
