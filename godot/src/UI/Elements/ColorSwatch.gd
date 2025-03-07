@tool
extends Button
class_name ColorSwatch

@onready var color_rect: ColorRect = $ColorRect

@export var color := Color('ffffff') : set = set_color


func _ready() -> void:
	self.color = color


func set_color(value: Color) -> void:
	color = value
	if not color_rect:
		await self.ready
	color_rect.color = value
