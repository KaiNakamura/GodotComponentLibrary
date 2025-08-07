class_name BulletComponent extends Node

signal collided(collision: KinematicCollision2D)

@export var character_body: CharacterBody2D
@export var look_at_component: LookAtComponent
@export var speed: float
@export var max_speed: float
@export var acceleration: float
@export var gravity: float
@export var gravity_direction: Vector2 = Vector2.DOWN
@export var enabled: bool = true

var has_initialized_speed: bool = false

func _ready() -> void:
	var direction = angle_to_direction(character_body.rotation)
	character_body.velocity = direction * speed

func accelerate() -> void:
	var delta = get_physics_process_delta_time()
	if acceleration > 0:
		var target_velocity := character_body.velocity.normalized() * max_speed
		character_body.velocity = character_body.velocity.move_toward(target_velocity, acceleration * delta)
	else:
		character_body.velocity = character_body.velocity.move_toward(Vector2.ZERO, -acceleration * delta)

func has_gravity() -> bool:
	return gravity != 0

func apply_gravity() -> void:
	character_body.velocity += gravity_direction * gravity

func limit_speed() -> void:
	character_body.velocity = character_body.velocity.limit_length(max_speed)

func set_direction_of_motion(direction: Vector2) -> void:
	if direction.length() == 0:
		return
	character_body.velocity = direction.normalized() * character_body.velocity.length()

func angle_to_direction(angle: float) -> Vector2:
	return Vector2.RIGHT.rotated(angle)

func set_angle_of_motion(angle: float) -> void:
	set_direction_of_motion(angle_to_direction(angle))

func _physics_process(_delta: float) -> void:
	update_velocity.call_deferred()

func update_velocity() -> void:
	if not enabled:
		return
	
	# Change velocity
	accelerate()

	if has_gravity():
		apply_gravity()
	
	limit_speed()

	# Move and collide
	var collision := character_body.move_and_collide(character_body.velocity * get_physics_process_delta_time())
	if collision:
		collided.emit(collision)

func bounce(normal: Vector2) -> void:
	var new_velocity := character_body.velocity.bounce(normal)
	character_body.velocity = new_velocity

func _process(delta: float) -> void:
	if look_at_component:
		look_at_component.look_in_direction(character_body.velocity)
