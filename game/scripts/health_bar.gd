extends Node2D


@onready var health_bar: Sprite2D = $Health
@onready var default_width = health_bar.region_rect.size.x
@onready var default_height = health_bar.region_rect.size.y

# Maximum health the bar represents when full. Defaults to 100 so existing
# entities (enemy_plant, mushroom, ...) keep working; bosses raise it.
var max_health: float = 100.0


func set_max_health(value: float) -> void:
	max_health = maxf(value, 1.0)


func update_health(new_health: int) -> void:
	# Resize health bar relative to max_health
	var ratio = clampf(new_health / max_health, 0.0, 1.0)
	var new_width = ratio * default_width
	health_bar.region_rect = Rect2(0, 0, new_width, default_height)
