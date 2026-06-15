extends Area2D


const LIFETIME: float = 2.0

var direction: Vector2 = Vector2.DOWN
var speed: float = 200.0
var damage: int = 12

var _elapsed: float = 0.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	# Play the spore animation once
	$AnimatedSprite2D.play("fly")


func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	_elapsed += delta
	if _elapsed >= LIFETIME:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" and body.has_method("take_damage"):
		body.take_damage(damage, global_position)
		queue_free()
	elif body.collision_layer & 4:
		# Hit a wall/furniture (layer 3 = bit 2 = value 4)
		queue_free()
