extends CharacterBody2D


signal died


const SPEED: float = 210.0
const KNOCKBACK_FORCE: float = 380.0
const ATTACK_DAMAGE: int = 27        # +50% (was 18)
const ATTACK_TRIGGER_RANGE: float = 93.75  # -25% (was 125)
const ATTACK_WINDUP: float = 0.12
const ATTACK_ACTIVE_TIME: float = 0.18
const ATTACK_COOLDOWN: float = 0.95

const MAX_HEALTH: int = 200

var is_alive: bool = true
var health: int = MAX_HEALTH
var target: Node2D = null
# Once damaged while the player is in sight, the boss locks on and never gives up.
var is_provoked: bool = false
var _music_started: bool = false

var _attack_cooldown_left: float = 0.0
var _is_attacking: bool = false
var _is_being_knocked_back: bool = false

@onready var sprite: Sprite2D = $Sprite
@onready var take_damage_sound: AudioStreamPlayer2D = $TakeDamage
@onready var health_bar: Node2D = $HealthBar
@onready var sight: Area2D = $Sight
@onready var attack_hitbox: Area2D = $AttackHitbox
@onready var spike_fx: AnimatedSprite2D = $SpikeFx


func _ready() -> void:
	attack_hitbox.monitoring = false
	if health_bar != null and health_bar.has_method("set_max_health"):
		health_bar.set_max_health(MAX_HEALTH)
	sight.body_entered.connect(_on_sight_body_entered)
	sight.body_exited.connect(_on_sight_body_exited)
	attack_hitbox.body_entered.connect(_on_attack_hitbox_body_entered)
	spike_fx.animation_finished.connect(_on_spike_fx_finished)


func _physics_process(delta: float) -> void:
	if _attack_cooldown_left > 0.0:
		_attack_cooldown_left = max(_attack_cooldown_left - delta, 0.0)

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

	var distance := global_position.distance_to(target.global_position)
	if distance <= ATTACK_TRIGGER_RANGE:
		velocity = Vector2.ZERO
		_try_attack()
	else:
		var direction := (target.global_position - global_position).normalized()
		velocity = direction * SPEED

	move_and_slide()


func _try_attack() -> void:
	if _is_attacking:
		return
	if _attack_cooldown_left > 0.0:
		return
	_attack_cooldown_left = ATTACK_COOLDOWN
	_is_attacking = true
	_do_attack()


func _do_attack() -> void:
	# Spike-strike visual telegraph + hit.
	spike_fx.visible = true
	spike_fx.frame = 0
	spike_fx.play("strike")

	# Wind-up
	await get_tree().create_timer(ATTACK_WINDUP).timeout
	if not is_alive:
		_is_attacking = false
		return
	attack_hitbox.monitoring = true
	await get_tree().create_timer(ATTACK_ACTIVE_TIME).timeout
	attack_hitbox.monitoring = false
	_is_attacking = false


func _on_spike_fx_finished() -> void:
	spike_fx.visible = false


func _on_attack_hitbox_body_entered(body: Node2D) -> void:
	if not is_alive:
		return
	if not attack_hitbox.monitoring:
		return
	if body == null:
		return
	# Damage only the player; otherwise we can end up calling enemy take_damage(damage, attacker_pos)
	# with the wrong signature.
	if body.name != "Player":
		return
	if body.has_method("take_damage"):
		body.take_damage(ATTACK_DAMAGE, global_position)


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
	attack_hitbox.monitoring = false
	AudioManager.clear_boss_music()
	AudioManager.play_sfx("boss_defeat")

	$CollisionShape2D.set_deferred("disabled", true)
	$Sight/CollisionShape2D.set_deferred("disabled", true)
	$AttackHitbox/CollisionShape2D.set_deferred("disabled", true)

	died.emit()

	var fade := create_tween()
	fade.tween_property(self, "modulate:a", 0.0, 0.6)
	fade.tween_callback(queue_free)


func _on_sight_body_entered(body: Node2D) -> void:
	if body != null and body.name == "Player":
		target = body
		if not _music_started:
			_music_started = true
			AudioManager.play_boss_music("boss_vine")


func _on_sight_body_exited(body: Node2D) -> void:
	if body != null and body.name == "Player" and is_alive:
		# A provoked boss keeps chasing even after the player leaves the area.
		if is_provoked:
			return
		target = null
