class_name KnockbackComponent extends Node

@export var character_body: CharacterBody2D

enum NamedEnum {ALL_DIRECTIONS, PLATFORMER}
@export var knockback_mode: NamedEnum = NamedEnum.ALL_DIRECTIONS

@export var knockback_multiplier: float = 1.0

func knockback_by_hitbox(hitbox: HitboxComponent) -> void:
	# Get the direction from the hitbox to the character
	var direction = (character_body.global_position - hitbox.global_position).normalized()

	# Apply the knockback
	apply_knockback(direction, hitbox.knockback * knockback_multiplier)

func apply_knockback(direction: Vector2, knockback: float) -> void:
	if not direction.is_normalized():
		direction = direction.normalized()

	match knockback_mode:
		NamedEnum.ALL_DIRECTIONS:
			apply_knockback_all_directions(direction, knockback)
		NamedEnum.PLATFORMER:
			apply_knockback_platformer(direction, knockback)

func apply_knockback_all_directions(direction: Vector2, knockback: float) -> void:
	character_body.velocity = direction * knockback

func apply_knockback_platformer(direction: Vector2, knockback: float) -> void:
	var new_direction = Vector2(sign(direction.x), -1).normalized()
	apply_knockback_all_directions(new_direction, knockback)