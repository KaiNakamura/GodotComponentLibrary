@tool
class_name ColoredCollisionShape2D extends CollisionShape2D

@export var color: Color = Color(1, 1, 1)

func _draw():
	if not shape:
		return
	
	if shape is RectangleShape2D:
		var extents = shape.size * 0.5
		draw_rect(Rect2(-extents, shape.size), color, true)
	elif shape is CircleShape2D:
		draw_circle(Vector2.ZERO, shape.radius, color)
	elif shape is CapsuleShape2D:
		# Note: Doesn't look correct with opacity because of overlapping shapes
		var height = shape.height
		var radius = shape.radius
		var half_height = (height - radius * 2) * 0.5  # Adjust for correct middle section
		
		# Draw central rectangle
		draw_rect(Rect2(Vector2(-radius, -half_height), Vector2(radius * 2, height - 2 * radius)), color, true)
		
		# Draw top and bottom circles without overlap
		draw_circle(Vector2(0, -half_height), radius, color)
		draw_circle(Vector2(0, half_height), radius, color)
	elif shape is SegmentShape2D:
		draw_line(shape.a, shape.b, color, 2.0)
	elif shape is ConvexPolygonShape2D:
		var points = shape.points
		draw_colored_polygon(points, color)
	
	queue_redraw()

func _process(_delta):
	queue_redraw()
