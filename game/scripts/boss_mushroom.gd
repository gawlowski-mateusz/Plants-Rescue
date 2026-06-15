extends CharacterBody2D


signal died


const SPEED: float = 70.0
const KNOCKBACK_FORCE: float = 260.0

const GAS_SLOW_MULTIPLIER: float = 0.55
const GAS_TICK_INTERVAL: float = 0.75
const GAS_DAMAGE_PER_TICK: int = 6

const MAX_HEALTH: int = 250

var is_alive: bool = true
var health: int = MAX_HEALTH
var target: Node2D = null
# Once damaged while the player is in sight, the boss locks on and never gives up.
var is_provoked: bool = false

var _is_being_knocked_back: bool = false
var _gas_target: Node2D = null
var _gas_tick_left: float = GAS_TICK_INTERVAL

@onready var sprite: Sprite2D = $Sprite
@onready var take_damage_sound: AudioStreamPlayer2D = $TakeDamage
@onready var health_bar: Node2D = $HealthBar
@onready var sight: Area2D = $Sight
@onready var gas_area: Area2D = $GasArea


func _ready() -> void:
	if health_bar != null and health_bar.has_method("set_max_health"):
		health_bar.set_max_health(MAX_HEALTH)
	sight.body_entered.connect(_on_sight_body_entered)
	sight.body_exited.connect(_on_sight_body_exited)
	gas_area.body_entered.connect(_on_gas_body_entered)
	gas_area.body_exited.connect(_on_gas_body_exited)


func _physics_process(delta: float) -> void:
	_process_gas(delta)

	if _is_being_knocked_back:
		move_and_slide()
		return

	if not is_alive:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if target == null or not is_instance_valid(target):
		target = null
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var direction := (target.global_position - global_position).normalized()
	velocity = direction * SPEED
	move_and_slide()


func _process_gas(delta: float) -> void:
	if not is_alive:
		return
	if _gas_target == null or not is_instance_valid(_gas_target):
		_gas_target = null
		_gas_tick_left = GAS_TICK_INTERVAL
		return

	_gas_tick_left = max(_gas_tick_left - delta, 0.0)
	if _gas_tick_left > 0.0:
		return

	if _gas_target.has_method("take_damage"):
		_gas_target.take_damage(GAS_DAMAGE_PER_TICK)
	_gas_tick_left = GAS_TICK_INTERVAL


func take_damage(damage: int, attacker_position: Vector2) -> void:
	if not is_alive:
		return

	health -= damage
	if health_bar != null and health_bar.has_method("update_health"):
		health_bar.update_health(health)

	if health <= 0:
		_die()
		return

	if take_damage_sound != null:
		take_damage_sound.play()
	_flash_red()
	_apply_knockback(attacker_position)
	# Hurt while the player is detected -> aggro-lock: no escape from now on.
	if is_instance_valid(target):
		is_provoked = true


func _flash_red() -> void:
	modulate = Color(1.5, 0.2, 0.2, 1.0)
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.25)


func _apply_knockback(attacker_position: Vector2) -> void:
	var knockback_dir := (global_position - attacker_position).normalized()
	_is_being_knocked_back = true
	velocity = knockback_dir * KNOCKBACK_FORCE

	var tween := create_tween()
	tween.tween_interval(0.12)
	tween.tween_callback(func():
		_is_being_knocked_back = false
		velocity = Vector2.ZERO
	)


func _die() -> void:
	is_alive = false
	velocity = Vector2.ZERO

	$CollisionShape2D.set_deferred("disabled", true)
	$Sight/CollisionShape2D.set_deferred("disabled", true)
	$GasArea/CollisionShape2D.set_deferred("disabled", true)

	if _gas_target != null and is_instance_valid(_gas_target):
		if _gas_target.has_method("clear_slow_multiplier"):
			_gas_target.clear_slow_multiplier()
	_gas_target = null

	died.emit()

	var fade := create_tween()
	fade.tween_property(self, "modulate:a", 0.0, 0.7)
	fade.tween_callback(queue_free)


func _on_sight_body_entered(body: Node2D) -> void:
	if body != null and body.name == "Player":
		target = body


func _on_sight_body_exited(body: Node2D) -> void:
	if body != null and body.name == "Player" and is_alive:
		# A provoked boss keeps chasing even after the player leaves the area.
		if is_provoked:
			return
		target = null


func _on_gas_body_entered(body: Node2D) -> void:
	if body != null and body.name == "Player":
		_gas_target = body
		_gas_tick_left = GAS_TICK_INTERVAL
		if body.has_method("set_slow_multiplier"):
			body.set_slow_multiplier(GAS_SLOW_MULTIPLIER)


func _on_gas_body_exited(body: Node2D) -> void:
	if body != null and body == _gas_target:
		if body.has_method("clear_slow_multiplier"):
			body.clear_slow_multiplier()
		_gas_target = null
		_gas_tick_left = GAS_TICK_INTERVAL
