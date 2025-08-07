class_name PlatformerComponent extends Node

signal switched_state(state: State)
signal jumped()
signal landed()

@export var character_body: CharacterBody2D
@export var look_at_component: LookAtComponent

## Squash and stretch component listens for "jump" and "land"
@export var squash_and_stretch_component: SquashAndStretchComponent

@export_group("Running")
@export var max_speed: float = 300
@export var acceleration: float = 6000
@export var deceleration: float = 6000

@export_group("Jumping")
@export var max_jump_height: float = 144
@export var min_jump_height: float = 24
@export var jump_rise_time: float = 0.4
@export var jump_fall_time: float = 0.3
@export var max_fall_speed: float = 10000
@export var coyote_time: float = 0.1:
	set(value):
		coyote_time = value
		if coyote_timer and has_coyote_time():
			coyote_timer.set_wait_time(coyote_time)
@export var infinite_mid_air_jumps: bool = false
@export var max_mid_air_jumps: int = 0

## Useful for things like fast-fall
@export var gravity_multiplier: float = 1

# TODO: Maybe (much) later add support for arbitrary ground normals
# TODO: Add sliding out from under ledges (i.e. anti-hit-your-head magic)
# TODO: Maybe add air drag (i.e. separate air friction from ground friction)

var state_machine: StateMachine

var moved_horizontally_this_frame: bool = false
var jump_held: bool = false
var coyote_timer: Timer = null
var mid_air_jumps_left: int

var jump_velocity: float
var jump_gravity: float
var fall_gravity: float
var jump_stop_gravity: float

func _calculate_jump_parameters():
	jump_velocity = (2 * max_jump_height) / jump_rise_time
	jump_gravity = (2 * max_jump_height) / pow(jump_rise_time, 2)
	fall_gravity = (2 * max_jump_height) / pow(jump_fall_time, 2)
	
	# Calculate jump stop gravity by using ratio between min/max jump height
	var height_ratio: float = min_jump_height / max_jump_height
	jump_stop_gravity = jump_gravity / height_ratio

func _ready() -> void:
	# Set up state machine
	state_machine = StateMachine.new()
	state_machine.actor = self
	state_machine.add_state(PlatformerComponentIdleState.new(), "idle")
	state_machine.add_state(PlatformerComponentRunState.new(), "run")
	state_machine.add_state(PlatformerComponentFallState.new(), "fall")
	state_machine.add_state(PlatformerComponentJumpState.new(), "jump")
	state_machine.set_initial_state("idle")
	add_child(state_machine)

	# Set up coyote timer
	coyote_timer = Timer.new()
	coyote_timer.set_one_shot(true)
	add_child(coyote_timer)
	if has_coyote_time():
		coyote_timer.set_wait_time(coyote_time)
	
	# Squash and stretch signals
	if squash_and_stretch_component:
		jumped.connect(func(): squash_and_stretch_component.play("jump"))
		landed.connect(func(): squash_and_stretch_component.play("land"))

func move_horizontally(direction: float) -> void:
	var delta = get_physics_process_delta_time()
	if direction:
		var target = direction * max_speed
		character_body.velocity.x = move_toward(
			character_body.velocity.x, target, acceleration * delta
		)
	else:
		decelerate()
	
	moved_horizontally_this_frame = true
	
	state_machine.current_state.handle_move_horizontally(direction)

func move_right() -> void:
	move_horizontally(1)

func move_left() -> void:
	move_horizontally(-1)

func decelerate() -> void:
	var delta = get_physics_process_delta_time()
	character_body.velocity.x = move_toward(
		character_body.velocity.x, 0, deceleration * delta
	)

func _get_gravity() -> float:
	var gravity: float
	if character_body.velocity.y >= 0:
		gravity = fall_gravity
	elif jump_held:
		gravity = jump_gravity
	else:
		gravity = jump_stop_gravity
	return gravity * gravity_multiplier

func move_vertically() -> void:
	_calculate_jump_parameters()
	
	var delta = get_physics_process_delta_time()
	
	if character_body.is_on_floor():
		reset_mid_air_jumps()
	else:
		# Apply gravity
		character_body.velocity.y += _get_gravity() * delta
	
	# Cap fall speed
	character_body.velocity.y = min(max_fall_speed, character_body.velocity.y)

func jump() -> void:
	if can_jump():
		character_body.velocity.y = -jump_velocity
		state_machine.current_state.handle_jump()
		
		# If we're not jumping from the ground, we must be jumping from the air,
		# so reduce number of mid-air jumps left
		if not can_jump_from_ground():
			mid_air_jumps_left -= 1

func can_jump_from_ground() -> bool:
	return character_body.is_on_floor() or is_coyote_time()

func can_jump_from_air() -> bool:
	return infinite_mid_air_jumps or mid_air_jumps_left > 0

func can_jump() -> bool:
	return can_jump_from_ground() or can_jump_from_air()

func _physics_process(delta: float) -> void:
	update_velocity.call_deferred()

func update_velocity() -> void:
	# If hasn't moved horizontally this frame, decelerate
	if not moved_horizontally_this_frame:
		decelerate()
	
	# Move vertically
	move_vertically()

	# Move and slide
	character_body.move_and_slide()
	
	# Hey why is this here and not at the end of move_vertically?
	# Well, it's here because it needs to go after the call to move_and_slide.
	# Otherwise, this causes issues with is_on_floor checks (e.g. from idle,
	# going to jump, then going straight back to idle because we hadn't left the
	# floor yet).
	state_machine.current_state.handle_move_vertically()

	# Reset moved horizontally flag
	moved_horizontally_this_frame = false

func _process(delta: float) -> void:
	if look_at_component:
		look_at_component.look_in_direction(Vector2(character_body.velocity.x, 0))

func has_coyote_time() -> bool:
	return coyote_time > 0

func is_coyote_time() -> bool:
	return has_coyote_time() and not coyote_timer.is_stopped()

func reset_mid_air_jumps() -> void:
	mid_air_jumps_left = max_mid_air_jumps

func is_idle() -> bool:
	return state_machine.get_current_state_name() == "idle"

func is_running() -> bool:
	return state_machine.get_current_state_name() == "run"

func is_jumping() -> bool:
	return state_machine.get_current_state_name() == "jump"

func is_falling() -> bool:
	return state_machine.get_current_state_name() == "fall"
