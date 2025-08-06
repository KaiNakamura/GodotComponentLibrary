class_name CarComponent extends Node

@export var character_body: CharacterBody2D
@export var look_at_component: LookAtComponent
@export var max_speed: float = 600
@export var acceleration: float = 150
@export var deceleration: float = 100
@export var max_reverse_speed: float = 100
@export var braking: float = 300
@export var turning_speed: float = 2
@export var min_speed_before_can_reverse: float = 150
@export var min_speed_before_can_steer: float = 75
@export var drift_friction: float = 0.018

var state_machine: StateMachine

var rotation: float
var velocity_changed_this_frame: bool = false

func _ready() -> void:
	# Set up state machine
	state_machine = StateMachine.new()
	state_machine.actor = self
	state_machine.add_state(CarComponentIdleState.new(), "idle")
	state_machine.add_state(CarComponentForwardState.new(), "forward")
	state_machine.add_state(CarComponentReverseState.new(), "reverse")
	state_machine.set_initial_state("idle")
	add_child(state_machine)
	
	# Initialize rotation
	rotation = character_body.rotation

func _get_direction() -> Vector2:
	return Vector2(cos(rotation), sin(rotation))

func _accelerate_to_velocity(acceleration_: float, velocity: Vector2, max_velocity: float) -> void:
	var delta = get_physics_process_delta_time()
	character_body.velocity = character_body.velocity.move_toward(velocity, acceleration_ * delta).limit_length(max_velocity)
	velocity_changed_this_frame = true

func _decelerate(amount: float) -> void:
	var delta = get_physics_process_delta_time()
	character_body.velocity = character_body.velocity.move_toward(Vector2.ZERO, amount * delta)
	velocity_changed_this_frame = true

func _apply_throttle(throttle_input: float) -> void:
	var velocity := _get_direction() * throttle_input * max_speed
	_accelerate_to_velocity(acceleration, velocity, max_speed)
	state_machine.current_state.handle_apply_throttle(throttle_input)

func _apply_brake(brake_input: float) -> void:
	state_machine.current_state.handle_apply_brake(brake_input)

func _apply_steering(steering_input: float) -> void:
	var delta = get_physics_process_delta_time()
	
	var min_speed_before_can_turn_factor: float = 1
	if min_speed_before_can_steer > 0:
		min_speed_before_can_turn_factor = min(1, lerpf(
			0,
			min_speed_before_can_steer,
			character_body.velocity.length()
		))
	rotation += min_speed_before_can_turn_factor * steering_input * turning_speed * delta

func apply_input(throttle_input: float, brake_input: float, steering_input: float) -> void:
	# Try to brake first if there's brake input (this allows you to tap brakes
	# while the throttle is down).
	if brake_input > 0:
		_apply_brake(brake_input)
	elif throttle_input > 0:
		_apply_throttle(throttle_input)
	
	_apply_steering(steering_input)

func _apply_braking_friction(braking_friciton: float) -> void:
	var delta = get_physics_process_delta_time()
	var forward_direction := _get_direction()
	var right_direction := forward_direction.rotated(PI / 2)
	var forward_velocity := character_body.velocity.dot(forward_direction)
	var right_velocity := character_body.velocity.dot(right_direction)
	
	character_body.velocity = \
		(forward_direction * forward_velocity * (1 - braking_friciton)) + \
		(right_direction * right_velocity)

func _apply_drift_friction() -> void:
	var delta = get_physics_process_delta_time()
	var forward_direction := _get_direction()
	var right_direction := forward_direction.rotated(PI / 2)
	var forward_velocity := character_body.velocity.dot(forward_direction)
	var right_velocity := character_body.velocity.dot(right_direction)
	
	character_body.velocity = \
		(forward_direction * forward_velocity) + \
		(right_direction * right_velocity * (1 - drift_friction))

func _physics_process(_delta: float) -> void:
	update_velocity.call_deferred()

func update_velocity() -> void:
	# If no velocity was changed this frame, deccelerate
	if not velocity_changed_this_frame:
		_decelerate(deceleration)
	
	_apply_drift_friction()
	
	# Move and slide
	character_body.move_and_slide()
	
	# Reset velocity changed flag
	velocity_changed_this_frame = false

func _process(delta: float) -> void:
	if look_at_component:
		look_at_component.set_looking_angle(rotation)
