extends Area2D


@export var speed: float = 520.0
@export var turn_strength: float = 8.0
@export var lifetime: float = 3.5
@export var damage: int = 12

var target: Node2D = null
var _direction: Vector2 = Vector2.RIGHT


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func setup(new_target: Node2D, initial_direction: Vector2, new_damage: int = 12) -> void:
	target = new_target
	damage = new_damage
	_direction = initial_direction.normalized()
	if _direction == Vector2.ZERO:
		_direction = Vector2.RIGHT
	rotation = _direction.angle()


func _physics_process(delta: float) -> void:
	if is_instance_valid(target):
		var desired := (target.global_position - global_position).normalized()
		if desired != Vector2.ZERO:
			_direction = _direction.lerp(desired, clampf(turn_strength * delta, 0.0, 1.0)).normalized()
			rotation = _direction.angle()

	global_position += _direction * speed * delta
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body == null:
		queue_free()
		return
	if body.name == "Player" and body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()
