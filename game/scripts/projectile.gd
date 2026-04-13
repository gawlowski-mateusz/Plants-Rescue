extends Area2D


const WATER := 0
const ACID := 1

const WATER_OUTER_COLOR := Color(0.18, 0.58, 1.0, 0.95)
const WATER_CORE_COLOR := Color(0.78, 0.93, 1.0, 0.95)
const ACID_OUTER_COLOR := Color(0.27, 0.86, 0.21, 0.95)
const ACID_CORE_COLOR := Color(0.78, 1.0, 0.43, 0.95)

@export var speed: float = 750.0
@export var lifetime: float = 1.2

var shot_kind: int = WATER
var direction: Vector2 = Vector2.RIGHT
var acid_damage: int = 20

@onready var outer: Polygon2D = $Outer
@onready var core: Polygon2D = $Core


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_apply_visual_style()


func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
	lifetime -= delta

	if lifetime <= 0.0:
		queue_free()


func setup(new_direction: Vector2, new_shot_kind: int, new_acid_damage: int) -> void:
	direction = new_direction.normalized()
	if direction == Vector2.ZERO:
		direction = Vector2.RIGHT

	shot_kind = new_shot_kind
	acid_damage = new_acid_damage
	rotation = direction.angle()
	_apply_visual_style()


func _apply_visual_style() -> void:
	if shot_kind == ACID:
		outer.color = ACID_OUTER_COLOR
		core.color = ACID_CORE_COLOR
		scale = Vector2.ONE * 1.05
		return

	outer.color = WATER_OUTER_COLOR
	core.color = WATER_CORE_COLOR
	scale = Vector2.ONE


func _on_body_entered(body: Node2D) -> void:
	if shot_kind == ACID and body.has_method("take_damage"):
		body.take_damage(acid_damage, global_position)
	elif shot_kind == WATER and body.has_method("water"):
		body.water()

	queue_free()