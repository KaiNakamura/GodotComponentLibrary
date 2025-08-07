class_name VelocityComponent extends Node

# NOTE: Movement functions should be called from _physics_process, not _process

@export var character_body: CharacterBody2D
@export var max_speed: float
@export var acceleration: float
@export var deceleration: float
@export var enabled: bool = true

## If true, the character will automatically deccelerate if no velocity is applied
@export var automatic_decceleration: bool = true

@export var look_at_component: LookAtComponent

var velocity_changed_this_frame: bool = false

func accelerate_to_velocity(velocity: Vector2) -> void:
	if not enabled:
		return
	
	var delta = get_physics_process_delta_time()
	character_body.velocity = character_body.velocity.move_toward(velocity, acceleration * delta).limit_length(max_speed)
	velocity_changed_this_frame = true

func decelerate() -> void:
	if not enabled:
		return
	
	var delta = get_physics_process_delta_time()
	character_body.velocity = character_body.velocity.move_toward(Vector2.ZERO, deceleration * delta)
	velocity_changed_this_frame = true

func get_max_velocity(direction: Vector2) -> Vector2:
	if not direction.is_normalized():
		direction = direction.normalized()
	return direction * max_speed

func move_in_direction(direction: Vector2) -> void:
	accelerate_to_velocity(direction * max_speed)

func maximize_velocity(direction: Vector2) -> void:
	if not enabled:
		return
	
	character_body.velocity = get_max_velocity(direction)
	velocity_changed_this_frame = true

# Returns true if the character is at the target position, otherwise returns false
func move_to(target_position: Vector2) -> bool:
	if not enabled:
		return false
	
	var direction_to_target = (target_position - character_body.position).normalized()
	var distance_to_target = target_position.distance_to(character_body.position)
	var current_speed = character_body.velocity.length()
	var deceleration_distance = (current_speed * current_speed) / (2 * deceleration)
	var is_at_target_position = false
	
	# Calculate target velocity considering deceleration
	var target_velocity = Vector2.ZERO
	if distance_to_target > deceleration_distance:
		target_velocity = direction_to_target * max_speed
	else:
		# Calculate deceleration needed to stop at the target position
		var deceleration_required = current_speed / (distance_to_target / current_speed)
		target_velocity = direction_to_target * max(min(deceleration_required, max_speed), 0)

	# If the character is very close to the target, snap to the target position to avoid jitter
	if distance_to_target < max_speed * get_physics_process_delta_time():
		character_body.position = target_position
		character_body.velocity = Vector2.ZERO
		is_at_target_position = true
	else:
		# Adjust velocity towards the target
		accelerate_to_velocity(target_velocity)

	velocity_changed_this_frame = true
	return is_at_target_position

func _physics_process(_delta: float) -> void:
	update_velocity.call_deferred()

func update_velocity() -> void:
	if not enabled:
		return
	
	# If automatic deceleration is enabled and no velocity was changed this frame, deccelerate
	if automatic_decceleration and not velocity_changed_this_frame:
		decelerate()

	# Move and slide
	character_body.move_and_slide()

	# Reset velocity changed flag
	velocity_changed_this_frame = false

func _process(delta: float) -> void:
	if look_at_component:
		look_at_component.look_in_direction(character_body.velocity)
