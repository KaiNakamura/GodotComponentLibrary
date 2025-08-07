class_name CarComponentForwardState extends CarComponentState

func handle_apply_throttle(throttle_input: float) -> void:
	pass

func handle_apply_brake(brake_input: float) -> void:
	var direction := get_car_component()._get_direction()
	var forward_velocity := get_character_body().velocity.dot(direction)
	
	# If not moving forward, go to idle
	if forward_velocity <= 0:
		transition_to.emit("idle")
		return
	
	# Otherwise, brake
	var braking := get_car_component().braking
	var max_speed := get_car_component().max_speed
	var velocity := -direction * brake_input * braking
	get_car_component()._accelerate_to_velocity(braking, velocity, max_speed)
