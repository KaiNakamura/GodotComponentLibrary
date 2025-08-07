class_name PlatformerComponentFallState extends PlatformerComponentState

func handle_move_vertically() -> void:
	if get_character_body().is_on_floor():
		transition_to.emit("idle")
		get_platformer_component().landed.emit()

func handle_jump() -> void:
	# Seems counter intuitive to handle jump during falling but this is for coyote time
	transition_to.emit("jump")
