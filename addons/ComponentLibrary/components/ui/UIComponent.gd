@tool
class_name UIComponent extends Control

func update_size() -> void:
	size.x = ProjectSettings.get_setting("display/window/size/viewport_width")
	size.y = ProjectSettings.get_setting("display/window/size/viewport_height")

func _ready() -> void:
	update_size()

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		update_size()
