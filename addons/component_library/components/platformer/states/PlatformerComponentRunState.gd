class_name PlatformerComponentRunState extends PlatformerComponentState

func handle_move_horizontally(direction: float) -> void:
	if direction == 0:
		transition_to.emit("idle")

func handle_move_vertically() -> void:
	if not get_character_body().is_on_floor():
		get_platformer_component().coyote_timer.start()
		transition_to.emit("fall")

func handle_jump() -> void:
	transition_to.emit("jump")
