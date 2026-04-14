extends CharacterBody2D


const SPEED: float = 100.0
const KNOCKBACK_FORCE: int = 100
const ATTACK_DAMAGE: int = 15
const ATTACK_INTERVAL: float = 0.8

var is_alive: bool = true
var health = 100
var target = null
var is_target_in_attack_range: bool = false
var attack_cooldown_left: float = 0.0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var take_damage_sound: AudioStreamPlayer2D = $TakeDamage
@onready var health_bar: Node2D = $HealthBar


func _physics_process(delta: float) -> void:
	if attack_cooldown_left > 0.0:
		attack_cooldown_left = max(attack_cooldown_left - delta, 0.0)

	if is_alive and target:
		if not is_instance_valid(target):
			target = null
			is_target_in_attack_range = false
			animated_sprite_2d.play("idle")
			return

		_attack(delta)

		if is_target_in_attack_range:
			_try_attack_target()
	

func _attack(delta: float) -> void:
	if is_target_in_attack_range:
		animated_sprite_2d.play("attack")
		return

	var direction = (target.position - position).normalized()
	position += direction * SPEED * delta
	animated_sprite_2d.play("attack")


func _try_attack_target() -> void:
	if attack_cooldown_left > 0.0:
		return

	if target and target.has_method("take_damage"):
		target.take_damage(ATTACK_DAMAGE)

	attack_cooldown_left = ATTACK_INTERVAL


func take_damage(damage: int, attacker_position: Vector2):
	health -= damage
	print(health)
	health_bar.update_health(health)
	
	if health <= 0:
		_die()
	else:
		take_damage_sound.play()
		var knockback_direction = (position - attacker_position).normalized()	
		var targer_position = position + knockback_direction * KNOCKBACK_FORCE
		var tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self, "position", targer_position, 0.5)
	
	
func _die() -> void:
	is_alive = false
	animated_sprite_2d.play("die")
	take_damage_sound.pitch_scale = 0.5
	take_damage_sound.play()
	
	# Disable collision
	$CollisionShape2D.set_deferred("disabled", true)
	$Sight/CollisionShape2D.set_deferred("disabled", true)
	$AttackHitbox/CollisionShape2D.set_deferred("disabled", true)

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
