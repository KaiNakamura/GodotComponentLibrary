class_name WeightedChoiceComponent extends Node

@export var pool: Dictionary[Variant, float] = {}

func pick() -> Variant:
	var weights := pool.values()
	var random_index := _weighted_random_choice(weights)
	return pool.keys()[random_index]
	
func _weighted_random_choice(weights: Array[float]) -> int:
	var total_weight: float = 0
	for weight in weights:
		total_weight += weight
	
	var random_value = randf() * total_weight
	for i in range(weights.size()):
		random_value -= weights[i]
		if random_value <= 0:
			return i
	
	# Return the last index if no other return has occurred
	return weights.size() - 1
