class_name PlatformerComponentJumpState extends PlatformerComponentState

func enter() -> void:
	get_platformer_component().coyote_timer.stop()
	get_platformer_component().jumped.emit()

func handle_move_vertically() -> void:
	if get_character_body().is_on_floor():
		transition_to.emit("idle")
		get_platformer_component().landed.emit()
	elif get_character_body().velocity.y > 0:
		transition_to.emit("fall")
