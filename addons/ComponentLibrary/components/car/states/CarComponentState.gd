class_name CarComponentState extends State

@warning_ignore("unused_parameter")
func handle_apply_throttle(throttle_input: float) -> void:
	pass

@warning_ignore("unused_parameter")
func handle_apply_brake(brake_input: float) -> void:
	pass

func get_car_component() -> CarComponent:
	return get_actor() as CarComponent

func get_character_body() -> CharacterBody2D:
	return get_car_component().character_body
