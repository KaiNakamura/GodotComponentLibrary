class_name RandomTimer extends Timer

@export var min_time: float = 1
@export var max_time: float = 3

func random_start() -> void:
	start(randf_range(min_time, max_time))
