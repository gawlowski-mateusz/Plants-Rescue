extends Node2D


@onready var water_fill: Sprite2D = $Water
@onready var default_width: float = water_fill.region_rect.size.x
@onready var default_height: float = water_fill.region_rect.size.y


func _ready() -> void:
	update_water(0)


func update_water(new_water_level: int) -> void:
	var clamped_water_level := clampi(new_water_level, 0, 100)
	var new_width := (clamped_water_level / 100.0) * default_width
	water_fill.region_rect = Rect2(0, 0, new_width, default_height)
