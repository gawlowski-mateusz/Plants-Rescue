extends CharacterBody2D


signal died


const SPEED: float = 100.0
const KNOCKBACK_FORCE: int = 100
const ATTACK_DAMAGE: int = 15
const ATTACK_INTERVAL: float = 0.8

var is_alive: bool = true
var health = 100
var target = null
var is_target_in_attack_range: bool = false
var attack_cooldown_left: float = 0.0
var is_being_knocked_back: bool = false

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var take_damage_sound: AudioStreamPlayer2D = $TakeDamage
@onready var health_bar: Node2D = $HealthBar


func _physics_process(delta: float) -> void:
	if attack_cooldown_left > 0.0:
		attack_cooldown_left = max(attack_cooldown_left - delta, 0.0)

	if is_being_knocked_back:
		move_and_slide()
		return

	if is_alive and target:
		if not is_instance_valid(target):
			target = null
			is_target_in_attack_range = false
			animated_sprite_2d.play("idle")
			velocity = Vector2.ZERO
			return

		_attack(delta)

		if is_target_in_attack_range:
			_try_attack_target()
	else:
		velocity = Vector2.ZERO

	move_and_slide()


func _attack(delta: float) -> void:
	if is_target_in_attack_range:
		# Player in range — stand still and play spine attack animation
		velocity = Vector2.ZERO
		animated_sprite_2d.play("spine_attack")
		return

	# Chase the player — play walk animation
	var direction = (target.position - position).normalized()
	velocity = direction * SPEED
	animated_sprite_2d.play("attack")


func _try_attack_target() -> void:
	if attack_cooldown_left > 0.0:
		return

	if target and target.has_method("take_damage"):
		target.take_damage(ATTACK_DAMAGE)

	attack_cooldown_left = ATTACK_INTERVAL


func take_damage(damage: int, attacker_position: Vector2):
	health -= damage
	health_bar.update_health(health)

	if health <= 0:
		_die()
	else:
		take_damage_sound.play()
		_flash_red()
		_apply_knockback(attacker_position)


func _flash_red() -> void:
	modulate = Color(1.5, 0.2, 0.2, 1.0)
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.25)


func _apply_knockback(attacker_position: Vector2) -> void:
	var knockback_dir = (position - attacker_position).normalized()
	is_being_knocked_back = true
	velocity = knockback_dir * KNOCKBACK_FORCE * 4.0

	var tween = create_tween()
	tween.tween_interval(0.15)
	tween.tween_callback(func():
		is_being_knocked_back = false
		velocity = Vector2.ZERO
	)


func _die() -> void:
	is_alive = false
	animated_sprite_2d.play("die")
	take_damage_sound.pitch_scale = 0.5
	take_damage_sound.play()
	velocity = Vector2.ZERO

	# Disable collision
	$CollisionShape2D.set_deferred("disabled", true)
	$Sight/CollisionShape2D.set_deferred("disabled", true)
	$AttackHitbox/CollisionShape2D.set_deferred("disabled", true)

	died.emit()


func _on_sight_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		target = body


func _on_sight_body_exited(body: Node2D) -> void:
	if body.name == "Player" and is_alive:
		target = null
		is_target_in_attack_range = false
		animated_sprite_2d.play("idle")


func _on_attack_hitbox_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		is_target_in_attack_range = true


func _on_attack_hitbox_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		is_target_in_attack_range = false
