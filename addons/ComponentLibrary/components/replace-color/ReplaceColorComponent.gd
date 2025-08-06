class_name ReplaceColorComponent extends Node
## Replaces a specific color of a CanvasItem with another color.
##
## Only works on CanvasItems with a texture (e.g. Sprite2D) and won't work on others well (e.g. CollisionShape2D, Polygon2D).
## See ColoredCollisionShape2D for a similar effect on CollisionShape2D.

## Shader used for replacing colors.
# var shader: Shader = preload("res://addons/ComponentLibrary/components/replace-color/shaders/ReplaceColorShader.gdshader")

## The target CanvasItems to which the shader material will be applied.
@export var target_items: Array[CanvasItem] = []:
	set(value):
		target_items = value
		update_color()

## The color in the texture that should be replaced.
@export var source_color: Color = Color(1, 0, 1):
	set(value):
		if source_color != value:
			source_color = value
			update_color()

## The color that will replace the source color.
@export var replace_color: Color = Color(1, 1, 1):
	set(value):
		if replace_color != value:
			replace_color = value
			update_color()

## The tolerance for color replacement. Colors within this range of the source color will be replaced.
@export var tolerance: float = 0.1:
	set(value):
		if tolerance != value:
			tolerance = value
			update_color()

func _ready() -> void:
	update_color()

## Updates the shader parameters and applies the shader material to the target items.
func update_color() -> void:
	for target_item in target_items:
		if target_item:
			var shader = load("res://addons/ComponentLibrary/components/replace-color/shaders/ReplaceColorShader.gdshader")
			var material = ShaderMaterial.new()
			material.shader = shader
			material.set_shader_parameter("target_color", source_color)
			material.set_shader_parameter("replacement_color", replace_color)
			material.set_shader_parameter("tolerance", tolerance)
			target_item.material = material
