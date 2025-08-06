class_name SquashAndStretchComponent extends Node

## If using in combination with other nodes that change scale, for example a
## LookAtComponent, use a parent Node2D to modify the scales separately

@export var nodes: Array[Node2D] = []
@export var lerp_speed: float = 2
@export var keyframes: Dictionary[String, Vector2] = {}

var original_scales: Array[Vector2] = []
var scale := Vector2.ONE

func play(keyframe_name: String) -> void:
	if not keyframes.has(keyframe_name):
		push_error("SquashAndStretchComponent could not find keyframe with name ", keyframe_name)
	
	scale = keyframes.get(keyframe_name)

func _initialize_original_scales() -> void:
	for node in nodes:
		if not node:
			push_warning("SquashAndStretchComponent has empty node")
			original_scales.append(Vector2.ONE)
		original_scales.append(node.scale)

func _ready() -> void:
	_initialize_original_scales()

func _process(delta: float) -> void:
	for i in range(nodes.size()):
		var node := nodes[i]
		if not node:
			continue
		
		var original_scale := original_scales[i]
		node.scale = original_scale * scale
	
	# Update scale
	scale = scale.move_toward(Vector2.ONE, lerp_speed * delta)
