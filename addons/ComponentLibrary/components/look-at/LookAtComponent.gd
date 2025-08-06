@tool
class_name LookAtComponent extends Node2D

## A component that makes nodes look at a target or in a direction
##
## To use nested LookAtComponents
## - Set the parent LookAtComponent to rotate the child
## - Set `ignore_parent_rotation` to true on the child

@export var nodes: Array[Node2D] = []

enum NamedEnum {SMOOTH, FOUR_DIRECTIONS, EIGHT_DIRECTIONS, FLIP_HORIZONTAL, FLIP_VERTICAL}
@export var look_at_mode: NamedEnum = NamedEnum.SMOOTH

var looking_direction := Vector2.RIGHT:
	set(value):
		looking_direction = value
		update()

## Threshold to prevent changing looking direction at very small values
@export var MIN_LOOKING_DIRECTION_THRESHOLD: float = 0.1

## Ignore parent rotation when calculating looking direction
@export var ignore_parent_rotation: bool = false

@export var preview_look_at_mouse: bool = false

func look_at_position(target: Vector2) -> void:
	looking_direction = target - global_position

func look_at_node(node: Node2D) -> void:
	look_at_position(node.global_position)

func look_in_direction(direction: Vector2) -> void:
	looking_direction = direction

## Angles in radians
func set_looking_angle(angle: float) -> void:
	var direction := Vector2(cos(angle), sin(angle))
	look_in_direction(direction)

func set_looking_angle_degrees(degrees: float) -> void:
	set_looking_angle(deg_to_rad(degrees))

func get_looking_angle() -> float:
	var angle = looking_direction.angle()
	return angle - rotation if ignore_parent_rotation else angle

func _get_snapped_angle(angle: float, snap_to: float) -> float:
	return round(angle / snap_to) * snap_to

func _get_valid_nodes() -> Array[Node]:
	var valid_nodes: Array[Node]
	for node in nodes:
		if node:
			valid_nodes.append(node)
	return valid_nodes

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		if preview_look_at_mouse:
			look_at_position(get_viewport().get_mouse_position())
		else:
			looking_direction = Vector2.RIGHT
	
	update()

func update() -> void:
	if not has_direction():
		return
	
	match look_at_mode:
		NamedEnum.SMOOTH:
			update_smooth()
		NamedEnum.FOUR_DIRECTIONS:
			update_four_directions()
		NamedEnum.EIGHT_DIRECTIONS:
			update_eight_directions()
		NamedEnum.FLIP_HORIZONTAL:
			update_flip_horizontal()
		NamedEnum.FLIP_VERTICAL:
			update_flip_vertical()

func update_smooth() -> void:
	var angle := get_looking_angle()
	for node in _get_valid_nodes():
		node.rotation = angle

func update_four_directions() -> void:
	var angle := get_looking_angle()
	for node in _get_valid_nodes():
		node.rotation = _get_snapped_angle(looking_direction.angle(), PI / 2)

func update_eight_directions() -> void:
	var angle := get_looking_angle()
	for node in _get_valid_nodes():
		node.rotation = _get_snapped_angle(looking_direction.angle(), PI / 4)

func update_flip_horizontal() -> void:
	# TODO: These may need fixing to work with parent rotation
	for node in _get_valid_nodes():
		var original_scale := abs(node.scale.x)
		node.scale.x = original_scale if looking_direction.x > 0 else -original_scale

func update_flip_vertical() -> void:
	# TODO: These may need fixing to work with parent rotation
	for node in _get_valid_nodes():
		var original_scale := abs(node.scale.y)
		node.scale.y = original_scale if looking_direction.y > 0 else -original_scale

func get_direction() -> Vector2:
	return looking_direction.normalized()

func has_direction() -> bool:
	return looking_direction.length() >= MIN_LOOKING_DIRECTION_THRESHOLD

func is_facing_right() -> bool:
	return has_direction() and looking_direction.x > 0
