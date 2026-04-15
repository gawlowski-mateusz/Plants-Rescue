extends CharacterBody2D
class_name FriendlyPlant


const MAX_WATER_LEVEL: int = 100
const WATER_PER_SHOT: int = 20

signal plant_fully_watered

var water_level: int = 0
var is_watered: bool = false

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var bloomed_sprite: Sprite2D = $BloomedSprite
@onready var water_bar: Node2D = $WaterBar
@onready var watered_label: Label = $WateredLabel


func _ready() -> void:
	animated_sprite_2d.play("idle")
	# Start pale/desaturated to show it's wilted
	animated_sprite_2d.modulate = Color(0.82, 0.86, 0.70, 1.0)
	watered_label.visible = false
	water_bar.update_water(water_level)


func water(amount: int = WATER_PER_SHOT) -> void:
	if is_watered:
		return

	water_level = clampi(water_level + amount, 0, MAX_WATER_LEVEL)
	water_bar.update_water(water_level)

	# Gradually brighten as it's watered
	var t := float(water_level) / float(MAX_WATER_LEVEL)
	animated_sprite_2d.modulate = Color(0.82, 0.86, 0.70, 1.0).lerp(Color(1.1, 1.2, 1.0, 1.0), t)

	if water_level >= MAX_WATER_LEVEL:
		is_watered = true
		_bloom()


func _bloom() -> void:
	# Swap to the bloomed sprite — the label is no longer needed,
	# since the new look makes the rescue visually obvious.
	watered_label.visible = false
	water_bar.visible = false
	_play_bloom_effect()
	plant_fully_watered.emit()


func _play_bloom_effect() -> void:
	# Flash white + scale up on the wilted sprite, then swap to the healthy one.
	var flash := create_tween().set_parallel(true)
	flash.tween_property(animated_sprite_2d, "modulate", Color(2.0, 2.0, 2.0, 1.0), 0.12)
	flash.tween_property(animated_sprite_2d, "scale", Vector2(2.0, 2.0), 0.12)

	await flash.finished

	# Hide the wilted animated sprite, show the bloomed pretty sprite
	animated_sprite_2d.visible = false
	bloomed_sprite.visible = true
	bloomed_sprite.modulate = Color(2.0, 2.0, 2.0, 1.0)
	bloomed_sprite.scale = Vector2(2.0, 2.0)

	var settle := create_tween().set_parallel(true)
	settle.tween_property(bloomed_sprite, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.45)
	settle.tween_property(bloomed_sprite, "scale", Vector2(1.5, 1.5), 0.45)

	await settle.finished

	# Gentle idle pulse so it feels alive
	var pulse := create_tween().set_loops()
	pulse.tween_property(bloomed_sprite, "scale", Vector2(1.55, 1.55), 1.2)
	pulse.tween_property(bloomed_sprite, "scale", Vector2(1.48, 1.48), 1.2)
