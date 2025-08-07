class_name HealthComponent extends Node

signal max_health_changed(max_health: int)
signal health_changed(health: int)
signal healed(amount: int)
signal damaged(amount: int)
signal died()

@export var progress_bar: ProgressBar
@export var max_health: int = 1: set = set_max_health
@export var health: int = 1: set = set_health

func set_max_health(_max_health: int) -> void:
	if max_health != _max_health:
		max_health = _max_health
		max_health_changed.emit(max_health)
	if health > max_health:
		health = max_health

func set_health(_health: int) -> void:
	if health != _health:
		health = _health
		health_changed.emit(health)
	if not has_health_remaining():
		died.emit()

func damage(amount: int) -> void:
	health -= amount
	damaged.emit(amount)

func kill() -> void:
	var amount := health
	health = 0
	damaged.emit(amount)

func heal(amount: int) -> void:
	var new_health = min(max_health, health + amount)
	var actual_amount = new_health - health
	health = new_health
	healed.emit(actual_amount)

func has_health_remaining() -> bool:
	return health > 0

func is_dead() -> bool:
	return not has_health_remaining()

func update_progress_bar() -> void:
	if progress_bar:
		progress_bar.value = health
		progress_bar.max_value = max_health

func _process(_delta: float) -> void:
	update_progress_bar()
