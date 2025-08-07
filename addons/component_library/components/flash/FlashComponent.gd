class_name FlashComponent extends Node

@export var canvas_items: Array[CanvasItem] = []
@export var flash_shader_material: ShaderMaterial = preload("res://addons/component_library/components/flash/shaders/WhiteShaderMaterial.tres")
@export var duration: float = 0.1
@export var num_flashes: int = 1
@export var disable_hurtbox_while_flashing: bool = true

var is_flashing: bool = false
var is_white: bool = false

func _wait(duration: float) -> void:
	var timer := Timer.new()
	add_child(timer)
	timer.start(duration)
	await timer.timeout
	timer.queue_free()

# TODO: This can run into issues if the shader material is being changed by something else
# Maybe change to something more robust in the future
# Doing a hot fix right now with the "is_white" stuff
# TODO: Also add functionality for different curves (e.g. flashing faster toward the end)
func flash() -> void:
	is_flashing = true
	
	var wait_time = duration / (2 * num_flashes - 1)
	for i in range(num_flashes):
		var original_materials = []
		for canvas_item in canvas_items:
			original_materials.append(canvas_item.material)
			canvas_item.material = flash_shader_material
		is_white = true
		await _wait(wait_time)
		for j in range(canvas_items.size()):
			canvas_items[j].material = original_materials[j]
		is_white = false
		
		if i < num_flashes - 1:
			await _wait(wait_time)
	
	is_flashing = false
