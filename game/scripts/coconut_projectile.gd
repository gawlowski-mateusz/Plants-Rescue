extends Area2D


@export var speed: float = 520.0
@export var turn_strength: float = 8.0
@export var lifetime: float = 3.5
@export var damage: int = 12

var target: Node2D = null
var _direction: Vector2 = Vector2.RIGHT
var _spin_speed: float = 12.0
var _trail_timer: float = 0.0
var _owner_body: Node2D = null
var _armed: bool = false

@onready var _visual: Node2D = null


func _ready() -> void:
	# Start with monitoring off — arm after a short delay so we don't hit our own spawner
	monitoring = false
	body_entered.connect(_on_body_entered)
	# Find the visual node (Sprite2D or Body polygon)
	if has_node("Sprite2D"):
		_visual = $Sprite2D
	elif has_node("Body"):
		_visual = $Body
	# Arm after a short delay to clear the spawner's body
	get_tree().create_timer(0.08).timeout.connect(func():
		_armed = true
		monitoring = true
	)


func setup(new_target: Node2D, initial_direction: Vector2, new_damage: int = 12, owner_body: Node2D = null) -> void:
	target = new_target
	damage = new_damage
	_owner_body = owner_body
	_direction = initial_direction.normalized()
	if _direction == Vector2.ZERO:
		_direction = Vector2.RIGHT
	# Spawn animation: pop in with scale
	scale = Vector2(0.3, 0.3)
	var tw := create_tween()
	tw.tween_property(self, "scale", Vector2(1.5, 1.5), 0.15).set_ease(Tween.EASE_OUT)


func _physics_process(delta: float) -> void:
	# Straight-line flight: the coconut is aimed at the player only at the moment
	# it is fired (see setup); it no longer homes in on a moving target.
	global_position += _direction * speed * delta

	# Spin the visual
	if _visual != null:
		_visual.rotation += _spin_speed * delta

	# Trail particles
	_trail_timer -= delta
	if _trail_timer <= 0.0:
		_trail_timer = 0.06
		_spawn_trail()

	lifetime -= delta
	if lifetime <= 0.0:
		_explode()


func _spawn_trail() -> void:
	var particle := Polygon2D.new()
	var points := PackedVector2Array()
	for i in range(6):
		var angle := i * TAU / 6.0
		points.append(Vector2(cos(angle), sin(angle)) * 4.0)
	particle.polygon = points
	particle.color = Color(0.55, 0.36, 0.18, 0.5)
	particle.global_position = global_position
	particle.z_index = -1
	get_tree().current_scene.add_child(particle)

	var tw := particle.create_tween()
	tw.set_parallel(true)
	tw.tween_property(particle, "modulate:a", 0.0, 0.3)
	tw.tween_property(particle, "scale", Vector2(0.2, 0.2), 0.3)
	tw.set_parallel(false)
	tw.tween_callback(particle.queue_free)


func _explode() -> void:
	# Small burst on expire/impact
	for i in range(5):
		var shard := Polygon2D.new()
		var pts := PackedVector2Array()
		for j in range(4):
			var a := j * TAU / 4.0
			pts.append(Vector2(cos(a), sin(a)) * randf_range(2.0, 5.0))
		shard.polygon = pts
		shard.color = Color(0.6, 0.4, 0.2, 0.8)
		shard.global_position = global_position
		get_tree().current_scene.add_child(shard)

		var dir := Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		var tw := shard.create_tween()
		tw.set_parallel(true)
		tw.tween_property(shard, "global_position", shard.global_position + dir * 30.0, 0.3)
		tw.tween_property(shard, "modulate:a", 0.0, 0.3)
		tw.tween_property(shard, "scale", Vector2(0.1, 0.1), 0.3)
		tw.set_parallel(false)
		tw.tween_callback(shard.queue_free)
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if not _armed:
		return
	if body == null:
		return
	# Only react to the Player — ignore furniture, walls, enemies
	if body.name != "Player":
		return
	if body.has_method("take_damage"):
		body.take_damage(damage, global_position)
	_explode()
