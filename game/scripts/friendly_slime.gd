extends CharacterBody2D


const MAX_WATER_LEVEL: int = 100
const WATER_PER_SHOT: int = 20

var water_level: int = 0
var is_watered: bool = false

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var water_bar: Node2D = $WaterBar
@onready var watered_label: Label = $WateredLabel


func _ready() -> void:
	animated_sprite_2d.play("idle")
	watered_label.visible = false
	water_bar.update_water(water_level)


func water(amount: int = WATER_PER_SHOT) -> void:
	if is_watered:
		return

	water_level = clampi(water_level + amount, 0, MAX_WATER_LEVEL)
	water_bar.update_water(water_level)

	if water_level >= MAX_WATER_LEVEL:
		is_watered = true
		watered_label.visible = true
