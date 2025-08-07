@tool
class_name RotateComponent extends Node

# Note: This class ma

@export var nodes: Array[Node2D]

## Rate of rotation in degrees per second
## Positive values for clockwise, negative for counter-clockwise
@export var speed: float = 90.0

@export var offset_angle: float = 0.0 ## degrees

@export var enabled: bool = true

## Whether to apply constant angular velocity to StaticBody2D nodes
@export var apply_constant_angular_velocity: bool = true

@export var preview_rotate: bool = false:
	set(value):
		preview_rotate = value
		if not preview_rotate:
			_reset_rotations()

var _original_rotations: Array[float] = []
var _accumulated_angle: float = 0.0

func _ready() -> void:
	_initialize_rotations()

func _initialize_rotations() -> void:
	_original_rotations.clear()
	for node in nodes:
		if node:
			_original_rotations.append(node.rotation)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	if not enabled:
		return

	_update_rotation(delta)

func _process(delta: float) -> void:
	if not Engine.is_editor_hint():
		return

	if preview_rotate:
		_update_rotation(delta)

func _update_rotation(delta: float) -> void:
	_accumulated_angle += speed * delta

	for i in min(nodes.size(), _original_rotations.size()):
		var node = nodes[i]
		if node:
			var base_rotation = _original_rotations[i]
			var total_rotation = base_rotation + deg_to_rad(offset_angle + _accumulated_angle)
			node.rotation = total_rotation

			if apply_constant_angular_velocity and node is StaticBody2D:
				node.constant_angular_velocity = deg_to_rad(speed)

func _reset_rotations() -> void:
	_accumulated_angle = 0.0

	if not _original_rotations.is_empty():
		for i in min(nodes.size(), _original_rotations.size()):
			var node = nodes[i]
			if node:
				node.rotation = _original_rotations[i]
