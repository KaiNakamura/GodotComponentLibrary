class_name CarComponentReverseState extends CarComponentState

func handle_apply_throttle(throttle_input: float) -> void:
	transition_to.emit("forward")

func handle_apply_brake(brake_input: float) -> void:
	var direction := get_car_component()._get_direction()
	var max_reverse_speed := get_car_component().max_reverse_speed
	var accleration := get_car_component().acceleration
	var velocity := -direction * brake_input * max_reverse_speed
	get_car_component()._accelerate_to_velocity(accleration, velocity, max_reverse_speed)
