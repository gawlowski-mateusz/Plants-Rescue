extends Area2D
class_name Door


@export var door_id: String = "door1"
@export var is_locked: bool = true

signal interacted(door_id: String)
signal opened(door_id: String)
signal player_near_changed(door_id: String, near: bool)

var _player_in_range: bool = false
var _is_open: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var lock_glow: Sprite2D = $Sprite2D/LockGlow
@onready var blocker: StaticBody2D = $Blocker
@onready var blocker_shape: CollisionShape2D = $Blocker/CollisionShape2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_refresh_visual()


func unlock() -> void:
	if not is_locked:
		return
	is_locked = false
	_refresh_visual()


func lock() -> void:
	if is_locked:
		return
	is_locked = true
	_refresh_visual()


func open() -> void:
	if _is_open:
		return
	_is_open = true
	# Remove physical blocker so player can pass through
	blocker_shape.set_deferred("disabled", true)
	# Opening animation: simply fade out
	var t := create_tween()
	t.tween_property(sprite, "modulate:a", 0.0, 0.35)
	t.tween_callback(func(): opened.emit(door_id))


func close() -> void:
	_is_open = false
	sprite.modulate.a = 1.0
	blocker_shape.set_deferred("disabled", false)


func is_player_near() -> bool:
	return _player_in_range


func _refresh_visual() -> void:
	if not is_node_ready():
		return
	if is_locked:
		# Reddish lock glow
		lock_glow.modulate = Color(1.0, 0.4, 0.4, 0.55)
		sprite.modulate = Color(0.85, 0.85, 0.95, 1.0)
	else:
		# Greenish ready glow
		lock_glow.modulate = Color(0.4, 1.0, 0.5, 0.65)
		sprite.modulate = Color(1.05, 1.05, 1.05, 1.0)


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		_player_in_range = true
		player_near_changed.emit(door_id, true)


func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		_player_in_range = false
		player_near_changed.emit(door_id, false)


func _unhandled_input(event: InputEvent) -> void:
	if not _player_in_range or _is_open:
		return
	if event.is_action_pressed("interact"):
		if is_locked:
			# Tiny shake to indicate it's locked
			var t := create_tween()
			t.tween_property(sprite, "position:x", sprite.position.x + 4, 0.05)
			t.tween_property(sprite, "position:x", sprite.position.x - 4, 0.05)
			t.tween_property(sprite, "position:x", sprite.position.x, 0.05)
		else:
			interacted.emit(door_id)
