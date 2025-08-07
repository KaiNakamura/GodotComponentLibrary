class_name CarComponentIdleState extends CarComponentState

func handle_apply_throttle(throttle_input: float) -> void:
	transition_to.emit("forward")

func handle_apply_brake(brake_input: float) -> void:
	# Only allow reversing if we're moving slow enough
	var min_speed_before_can_reverse := get_car_component().min_speed_before_can_reverse
	if get_character_body().velocity.length() <= min_speed_before_can_reverse:
		transition_to.emit("reverse")
