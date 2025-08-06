class_name BoundToViewportComponent extends Node

signal entered_viewport()
signal exited_viewport()

@export var actor: Node2D
@export var bind_to_viewport: bool = true
@export var wrap_horizontal: bool = false
@export var wrap_vertical: bool = false
@export var padding: Vector2 = Vector2.ZERO

var was_on_screen: bool

func _ready() -> void:
	was_on_screen = is_on_screen()

func _get_viewport_rect() -> Rect2:
	return get_viewport().get_visible_rect()

func _get_min_x() -> float:
	return _get_viewport_rect().position.x - padding.x

func _get_max_x() -> float:
	return _get_viewport_rect().position.x + _get_viewport_rect().size.x + padding.x

func _get_min_y() -> float:
	return _get_viewport_rect().position.y - padding.y

func _get_max_y() -> float:
	return _get_viewport_rect().position.y + _get_viewport_rect().size.y + padding.y

func is_on_screen() -> bool:
	return actor.global_position.x >= _get_min_x() and \
		actor.global_position.x <= _get_max_x() and \
		actor.global_position.y >= _get_min_y() and \
		actor.global_position.y <= _get_max_y()

func _physics_process(delta: float) -> void:
	# Emit signals for entering/exiting viewport
	var on_screen := is_on_screen()
	if on_screen and not was_on_screen:
		entered_viewport.emit()
	elif not on_screen and was_on_screen:
		exited_viewport.emit()
	
	var viewport_rect = get_viewport().get_visible_rect()
	var min_x: float = _get_min_x()
	var max_x: float = _get_max_x()
	var min_y: float = _get_min_y()
	var max_y: float = _get_max_y()
	
	if wrap_horizontal:
		if actor.global_position.x < min_x:
			actor.global_position.x = max_x
		elif actor.global_position.x > max_x:
			actor.global_position.x = min_x
	
	if wrap_vertical:
		if actor.global_position.y < min_y:
			actor.global_position.y = max_y
		elif actor.global_position.y > max_y:
			actor.global_position.y = min_y
	
	if bind_to_viewport:
		actor.global_position.x = clamp(actor.global_position.x, min_x, max_x)
		actor.global_position.y = clamp(actor.global_position.y, min_y, max_y)
	
	was_on_screen = on_screen
