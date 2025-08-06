@tool
class_name HurtboxComponent extends Area2D

## An Area2D that represents a vulnerable area of an object.
## It listens for collisions with HitboxComponents, which represent damaging areas of other objects.
## The HurtboxComponent should exist on one or more collision masks and no collision layers.

signal hit_by_hitbox(hitbox: HitboxComponent)

## The HealthComponent that manages the health of the object.
@export var health_component: HealthComponent

## The FlashComponent that flashes the object
@export var flash_component: FlashComponent

## The KnockbackComponent that applies knockback to the object
@export var knockback_component: KnockbackComponent

## Whether the hurtbox is enabled.
@export var enabled: bool = true : set = set_enabled

## HitboxComponent flags that the hurtbox ignores
@export var ignore_flags: Array[Variant] = []

func update_collision_shape_color() -> void:
	for child in get_children():
		if child is CollisionShape2D:
			child.debug_color = Color(0, 1, 0, 0.1)

func _ready():
	update_collision_shape_color()
	connect("area_entered", _on_area_entered)

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		update_collision_shape_color()

func _on_area_entered(area: Area2D) -> void:
	if flash_component and flash_component.disable_hurtbox_while_flashing and flash_component.is_flashing:
		return

	if area is HitboxComponent:
		var hitbox := area as HitboxComponent

		# Check if the hurtbox ignores the hitbox's flags
		for flag in hitbox.flags:
			if ignore_flags.has(flag):
				return

		if health_component:
			health_component.damage(area.get_damage())
		if flash_component:
			flash_component.flash()
		if hitbox.has_knockback() and knockback_component:
			knockback_component.knockback_by_hitbox(hitbox)
		hit_by_hitbox.emit(hitbox)
		hitbox.hit_hurtbox.emit(self)

func set_enabled(_enabled: bool) -> void:
	enabled = _enabled
	for child in get_children():
		if child is CollisionShape2D:
			child.disabled = not enabled

func add_ignore_flag(flag: Variant) -> void:
	if not ignore_flags.has(flag):
		ignore_flags.append(flag)

func remove_ignore_flag(flag: Variant) -> void:
	if ignore_flags.has(flag):
		ignore_flags.erase(flag)
