@tool
class_name HitboxComponent extends Area2D

## An Area2D that represents a damaging area of an object.
## It listens for collisions with HurtboxComponents, which represent vulnerable areas of other objects.
## The HitboxComponent should exist on one or more collision layers and no collision masks.

signal hit_hurtbox(hurtbox: HurtboxComponent)

## The amount of damage that the hitbox deals.
@export var damage: int = 1 : set = set_damage, get = get_damage

## The amount of knockback that the hitbox deals.
@export var knockback: float = 0

## Whether the hitbox is enabled.
@export var enabled: bool = true : set = set_enabled

## Flags that can be used to determine the type of hitbox. Useful for
## determining the owner of a hitbox or creating hurtboxes that ignore certain
## hitboxes.
@export var flags: Array[Variant] = []

func update_collision_shape_color() -> void:
	for child in get_children():
		if child is CollisionShape2D:
			child.debug_color = Color(1, 0, 0, 0.1)

func _ready() -> void:
	update_collision_shape_color()

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		update_collision_shape_color()

func set_damage(_damage: int):
	damage = _damage

func get_damage() -> int:
	return damage

func has_knockback() -> bool:
	return knockback > 0

func set_enabled(_enabled: bool) -> void:
	enabled = _enabled
	for child in get_children():
		if child is CollisionShape2D:
			child.disabled = not enabled

func add_flag(flag: Variant) -> void:
	if not flags.has(flag):
		flags.append(flag)

func remove_flag(flag: Variant) -> void:
	if flags.has(flag):
		flags.erase(flag)
