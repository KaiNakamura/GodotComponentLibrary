@tool
class_name DetectorComponent extends Area2D

## An Area2D that represents a detection area for an object.
## It listens for collisions with HurtboxComponents, which represent vulnerable areas of other objects.
## The HitboxComponent should exist on one or more collision layers and no collision masks.

signal target_entered(body: Node)
signal target_exited(body: Node)

var target: Node = null

func update_collision_shape_color() -> void:
	for child in get_children():
		if child is CollisionShape2D:
			child.debug_color = Color(1, 1, 0, 0.1)

func _ready() -> void:
	update_collision_shape_color()
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		update_collision_shape_color()

func _on_body_entered(body: Node) -> void:
	# Check if the body is an instance of the specified class name
	emit_signal("target_entered", body)
	target = body

func _on_body_exited(body: Node) -> void:
	if not has_target():
		return

	# Check if target left the detection area
	if body == target:
		emit_signal("target_exited", body)
		target = null

func has_target() -> bool:
	return target != null
