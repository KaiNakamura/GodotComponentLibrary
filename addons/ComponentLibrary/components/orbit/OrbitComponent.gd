@tool
class_name OrbitComponent extends Node

@export var nodes: Array[Node2D]

@export var speed: float = 90.0 ## deg / s
@export var acceleration: float = 0.0 ## deg / s^2
@export var radius: Vector2 = Vector2(64, 64) ## pixels
@export var offset_angle: float = 0.0 ## degrees
@export var match_rotation: bool = false
@export var enabled: bool = true

@export var preview_orbit: bool = false:
	set(value):
		preview_orbit = value

		if preview_orbit:
			_initialize_centers()
			_current_angle = 0.0
		else:
			if not _center_positions.is_empty():
				for i in min(nodes.size(), _center_positions.size()):
					var node = nodes[i]
					if node:
						node.global_position = _center_positions[i]

			_current_angle = 0.0

var _current_angle: float = 0.0 ## degrees
var _center_positions: Array[Vector2] = []

func _ready() -> void:
	_initialize_centers()

func _initialize_centers() -> void:
	_center_positions.clear()
	for node in nodes:
		if node:
			_center_positions.append(node.global_position)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	if not enabled:
		return

	_update_orbit(delta)

func _process(delta: float) -> void:
	if not Engine.is_editor_hint():
		return

	if preview_orbit:
		_update_orbit(delta)

func _update_orbit(delta: float) -> void:
	# Update speed with acceleration
	speed += acceleration * delta

	# Update orbit angle
	_current_angle += speed * delta

	for i in min(nodes.size(), _center_positions.size()):
		var node = nodes[i]
		if node:
			var center = _center_positions[i]

			var angle_rad = deg_to_rad(_current_angle + offset_angle)
			var x = center.x + radius.x * cos(angle_rad)
			var y = center.y + radius.y * sin(angle_rad)
			node.global_position = Vector2(x, y)

			if match_rotation:
				node.rotation = angle_rad
