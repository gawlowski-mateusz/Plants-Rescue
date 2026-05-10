extends CharacterBody2D
class_name FriendlyPlant


const MAX_WATER_LEVEL: int = 100
const WATER_PER_SHOT: int = 20

const DEFAULT_ENEMY_SCALE: Vector2 = Vector2(2.0, 2.0)

@export var corrupted_enemy_scene: PackedScene = preload("res://scenes/slime.tscn")

signal plant_fully_watered
signal corrupted_into_enemy(enemy: Node2D)

var water_level: int = 0
var is_watered: bool = false
var _is_corrupted: bool = false

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
	if _is_corrupted:
		return

	water_level = clampi(water_level + amount, 0, MAX_WATER_LEVEL)
	water_bar.update_water(water_level)

	# Gradually brighten as it's watered
	var t := float(water_level) / float(MAX_WATER_LEVEL)
	animated_sprite_2d.modulate = Color(0.82, 0.86, 0.70, 1.0).lerp(Color(1.1, 1.2, 1.0, 1.0), t)

	if water_level >= MAX_WATER_LEVEL:
		is_watered = true
		_bloom()


func take_damage(_damage: int, _attacker_position: Vector2) -> void:
	# Friendly plants can be corrupted into enemies by acid or scissors.
	if is_watered:
		return
	if _is_corrupted:
		return
	_corrupt_into_enemy()


func _corrupt_into_enemy() -> void:
	_is_corrupted = true
	if corrupted_enemy_scene == null:
		queue_free()
		return

	var enemy = corrupted_enemy_scene.instantiate()
	if enemy == null:
		queue_free()
		return

	var enemy_node := enemy as Node2D
	if enemy_node != null:
		enemy_node.global_position = global_position
		enemy_node.scale = DEFAULT_ENEMY_SCALE

	var scene_root := get_tree().current_scene
	var enemies_container: Node = null
	if scene_root != null:
		enemies_container = scene_root.get_node_or_null("Enemies")

	if enemies_container != null:
		enemies_container.add_child(enemy)
	else:
		get_parent().add_child(enemy)

	if enemy_node != null:
		corrupted_into_enemy.emit(enemy_node)
	else:
		# Fallback, should not happen with current enemy scenes.
		corrupted_into_enemy.emit(null)

	queue_free()


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
