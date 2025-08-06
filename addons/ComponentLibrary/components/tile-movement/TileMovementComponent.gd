@tool
class_name TileMovementComponent extends Node2D

@export var character_body: CharacterBody2D
@export var tile_size: Vector2 = Vector2(16, 16)
@export var tile_offset: Vector2 = Vector2.ZERO
@export var set_tile_offset_to_init_position: bool = true
@export var move_speed: float
@export var snapping_distance: float = 4

## Shape casts should extend slightly beyond character body collision shape
@export_group("Shape Casts")
@export var shape_cast_offset: float
@export var shape_cast_length: float
@export var shape_cast_width: float
@export var preview_shape_casts: bool = false

var left_shape_cast: ShapeCast2D
var right_shape_cast: ShapeCast2D
var up_shape_cast: ShapeCast2D
var down_shape_cast: ShapeCast2D

enum Direction {LEFT, RIGHT, UP, DOWN}

func _destroy_shape_casts() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()

func _create_shape_cast(direction: Direction) -> ShapeCast2D:
	# Create rectangle shape
	var shape := RectangleShape2D.new()
	if direction == Direction.LEFT or direction == Direction.RIGHT:
		shape.size.x = shape_cast_length
		shape.size.y = shape_cast_width
	else:
		shape.size.x = shape_cast_width
		shape.size.y = shape_cast_length
	
	var shape_cast := ShapeCast2D.new()
	shape_cast.shape = shape
	shape_cast.position = (shape_cast_offset + shape_cast_length / 2.0) * _get_vector_from_direction(direction)
	shape_cast.target_position = position
	shape_cast.collision_mask = character_body.collision_mask
	add_child(shape_cast)
	return shape_cast

func _update_shape_casts() -> void:
	if not character_body:
		push_warning("TileMovementComponent could not create ray casts, missing CharacterBody2D")
		return
	
	# Remove all shape casts
	_destroy_shape_casts()
	
	# Create new shape casts
	left_shape_cast = _create_shape_cast(Direction.LEFT)
	right_shape_cast = _create_shape_cast(Direction.RIGHT)
	up_shape_cast = _create_shape_cast(Direction.UP)
	down_shape_cast = _create_shape_cast(Direction.DOWN)

func _ready() -> void:
	_update_shape_casts()
	if set_tile_offset_to_init_position:
		tile_offset = global_position

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		if preview_shape_casts:
			_update_shape_casts()
		else:
			_destroy_shape_casts()

func _update_position(direction: Vector2) -> void:
	pass

func _get_vector_from_direction(direction: Direction) -> Vector2:
	match (direction):
		Direction.LEFT:
			return Vector2.LEFT
		Direction.RIGHT:
			return Vector2.RIGHT
		Direction.UP:
			return Vector2.UP
		Direction.DOWN:
			return Vector2.DOWN
		_:
			push_error("_get_vector_from_direction unexpected direction")
			return Vector2.ZERO

func can_move_left() -> bool:
	return not left_shape_cast.is_colliding()

func can_move_right() -> bool:
	return not right_shape_cast.is_colliding()

func can_move_up() -> bool:
	return not up_shape_cast.is_colliding()

func can_move_down() -> bool:
	return not down_shape_cast.is_colliding()

func _can_move_in_direction(direction: Direction) -> bool:
	match (direction):
		Direction.LEFT:
			return can_move_left()
		Direction.RIGHT:
			return can_move_right()
		Direction.UP:
			return can_move_up()
		Direction.DOWN:
			return can_move_down()
		_:
			push_error("_can_move_in_direction unexpected direction")
			return false

func _global_position_to_grid(point: Vector2) -> Vector2:
	return point - tile_offset

func _grid_to_global_position(point: Vector2) -> Vector2:
	return point + tile_offset

func _snap_x(x: float) -> float:
	return roundf(x / tile_size.x) * tile_size.x

func _snap_left(x: float) -> float:
	return floorf(x / tile_size.x) * tile_size.x

func _snap_right(x: float) -> float:
	return ceilf(x / tile_size.x) * tile_size.x

func _snap_y(y: float) -> float:
	return roundf(y / tile_size.y) * tile_size.y

func _snap_up(y: float) -> float:
	return floorf(y / tile_size.y) * tile_size.y

func _snap_down(y: float) -> float:
	return ceilf(y / tile_size.y) * tile_size.y

func _distance_to_snap_x(x: float) -> float:
	return abs(x - _snap_x(x))

func _distance_to_snap_left(x: float) -> float:
	return abs(x - _snap_left(x))

func _distance_to_snap_right(x: float) -> float:
	return abs(x - _snap_right(x))

func _distance_to_snap_y(y: float) -> float:
	return abs(y - _snap_y(y))

func _distance_to_snap_up(y: float) -> float:
	return abs(y - _snap_up(y))

func _distance_to_snap_down(y: float) -> float:
	return abs(y - _snap_down(y))

func _get_snapped_position(point: Vector2) -> Vector2:
	return Vector2(
		_snap_x(point.x),
		_snap_y(point.y)
	)

func _get_snapped_x_position(point: Vector2) -> Vector2:
	return Vector2(_snap_x(point.x), point.y)

func _get_snapped_left_position(point: Vector2) -> Vector2:
	return Vector2(_snap_left(point.x), point.y)

func _get_snapped_right_position(point: Vector2) -> Vector2:
	return Vector2(_snap_right(point.x), point.y)

func _get_snapped_y_position(point: Vector2) -> Vector2:
	return Vector2(point.x, _snap_y(point.y))

func _get_snapped_up_position(point: Vector2) -> Vector2:
	return Vector2(point.x, _snap_up(point.y))

func _get_snapped_down_position(point: Vector2) -> Vector2:
	return Vector2(point.x, _snap_down(point.y))

func _get_snapped_position_in_direction(point: Vector2, direction: Direction) -> Vector2:
	var snapped_position: Vector2
	match (direction):
		Direction.LEFT:
			return _get_snapped_left_position(point)
		Direction.RIGHT:
			return _get_snapped_right_position(point)
		Direction.UP:
			return _get_snapped_up_position(point)
		Direction.DOWN:
			return _get_snapped_down_position(point)
		_:
			push_error("_get_snapped_position_in_direction unexpected direction")
			return Vector2.ZERO

func _is_on_vertical_line(x: float) -> bool:
	return _distance_to_snap_x(x) < snapping_distance

func _is_on_horizontal_line(y: float) -> bool:
	return _distance_to_snap_y(y) < snapping_distance

func _is_not_axis_aligned(direction: Vector2) -> bool:
	return direction.x != 0 and direction.y != 0

func move_in_direction(delta: float, move_input: Vector2) -> void:
	# No movement if the move input is zero
	if move_input.length() == 0:
		return
	
	var abs_x := abs(move_input.x)
	var abs_y := abs(move_input.y)
	
	var primary_direction: Direction
	var secondary_direction: Direction
	if abs_x >= abs_y and abs_x > 0:
		primary_direction = Direction.RIGHT if move_input.x > 0 else Direction.LEFT
		if abs_y > 0:
			secondary_direction = Direction.DOWN if move_input.y > 0 else Direction.UP
	elif abs_y > abs_x and abs_y > 0:
		primary_direction = Direction.DOWN if move_input.y > 0 else Direction.UP
		if abs_x > 0:
			secondary_direction = Direction.RIGHT if move_input.x > 0 else Direction.LEFT
	else:
		push_warning("Something went wrong in move_in_direction, shouldn't reach here")
		return
	
	# Try to move in primary direction, if unsuccessful try secondary direction
	if _attempt_to_move_in_direction(delta, primary_direction):
		return
	elif _attempt_to_move_in_direction(delta, secondary_direction):
		return

# Try to move in a direction, returns whether was successful
func _attempt_to_move_in_direction(delta: float, direction: Direction) -> bool:
	var grid_position := _global_position_to_grid(character_body.global_position)
	var change_in_position := _get_vector_from_direction(direction) * move_speed * delta
	var travel_distance := change_in_position.length()
	var new_grid_position := grid_position + change_in_position
	
	var is_on_vertical_line := _is_on_vertical_line(new_grid_position.x)
	var is_on_horizontal_line := _is_on_horizontal_line(new_grid_position.y)
	
	var snapped_position: Vector2
	
	# If for some reason we left the grid, snap back to it, try again
	if not is_on_vertical_line and not is_on_horizontal_line:
		snapped_position = _get_snapped_position(new_grid_position)
		character_body.global_position = _grid_to_global_position(snapped_position)
		return _attempt_to_move_in_direction(delta, direction)
	
	match (direction):
		Direction.LEFT:
			if is_on_horizontal_line and can_move_left():
				snapped_position = _get_snapped_y_position(new_grid_position)
		Direction.RIGHT:
			if is_on_horizontal_line and can_move_right():
				snapped_position = _get_snapped_y_position(new_grid_position)
		Direction.UP:
			if is_on_vertical_line and can_move_up():
				snapped_position = _get_snapped_x_position(new_grid_position)
		Direction.DOWN:
			if is_on_vertical_line and can_move_down():
				snapped_position = _get_snapped_x_position(new_grid_position)
		_:
			push_error("_attempt_to_move_in_direction unexpected direction")
	
	if not snapped_position:
		return false
	
	character_body.global_position = _grid_to_global_position(snapped_position)
	character_body.move_and_slide()
	return true
