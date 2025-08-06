class_name PlatformerComponentState extends State

## Note: Use handle_move_horizontally and handle_move_vertically where
## appropriate instead of update and physics_update. This is because is_on_floor
## checks can have unexpected behavior otherwise (e.g. from idle, going to jump,
## then going straight back to idle because we hadn't left the floor yet).

@warning_ignore("unused_parameter")
func handle_move_horizontally(direction: float) -> void:
	pass

func handle_move_vertically() -> void:
	pass

func handle_jump() -> void:
	pass

func get_platformer_component() -> PlatformerComponent:
	return get_actor() as PlatformerComponent

func get_character_body() -> CharacterBody2D:
	return get_platformer_component().character_body
