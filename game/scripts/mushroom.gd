extends CharacterBody2D


signal died


const SPEED: float = 80.0
const KNOCKBACK_FORCE: int = 100
const ATTACK_DAMAGE: int = 12
const ATTACK_INTERVAL: float = 1.5
const PROJECTILE_SPEED: float = 200.0

@export var spore_projectile_scene: PackedScene = preload("res://scenes/spore_projectile.tscn")

# Used as the level-2 mid-boss (bedroom), so it gets a boss-sized health pool.
const MAX_HEALTH: int = 250

var is_alive: bool = true
var health: int = MAX_HEALTH
var target: Node2D = null
var is_target_in_attack_range: bool = false
var attack_cooldown_left: float = 0.0
var is_being_knocked_back: bool = false
var _is_attacking: bool = false
# Once damaged while the player is in sight, it locks on and never gives up.
var is_provoked: bool = false
var _music_started: bool = false

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var take_damage_sound: AudioStreamPlayer2D = $TakeDamage
@onready var health_bar: Node2D = $HealthBar


func _ready() -> void:
	if health_bar != null and health_bar.has_method("set_max_health"):
		health_bar.set_max_health(MAX_HEALTH)
	animated_sprite_2d.animation_finished.connect(_on_animation_finished)


func _physics_process(delta: float) -> void:
	if attack_cooldown_left > 0.0:
		attack_cooldown_left = max(attack_cooldown_left - delta, 0.0)

	if is_being_knocked_back:
		move_and_slide()
		return

	if not is_alive:
		return

	if target and is_instance_valid(target):
		if is_target_in_attack_range:
			_try_attack_target()
		elif not _is_attacking:
			_chase(delta)
	else:
		target = null
		is_target_in_attack_range = false
		velocity = Vector2.ZERO
		if not _is_attacking:
			animated_sprite_2d.play("idle")

	move_and_slide()


func _chase(_delta: float) -> void:
	var direction = (target.global_position - global_position).normalized()
	velocity = direction * SPEED

	# Choose walk animation based on direction
	if abs(direction.x) > abs(direction.y):
		animated_sprite_2d.play("walk_east")
		animated_sprite_2d.flip_h = direction.x < 0
	else:
		animated_sprite_2d.play("walk_south")
		animated_sprite_2d.flip_h = false


func _try_attack_target() -> void:
	velocity = Vector2.ZERO

	if attack_cooldown_left > 0.0:
		if not _is_attacking:
			animated_sprite_2d.play("idle")
		return

	_is_attacking = true
	animated_sprite_2d.play("attack")
	attack_cooldown_left = ATTACK_INTERVAL


func _on_animation_finished() -> void:
	if animated_sprite_2d.animation == "attack":
		_is_attacking = false
		_shoot_spore()
	elif animated_sprite_2d.animation == "die":
		queue_free()


func _shoot_spore() -> void:
	if not is_alive or target == null or not is_instance_valid(target):
		return
	if spore_projectile_scene == null:
		return

	var projectile = spore_projectile_scene.instantiate()
	projectile.global_position = global_position
	var dir = (target.global_position - global_position).normalized()
	projectile.direction = dir
	projectile.speed = PROJECTILE_SPEED
	projectile.damage = ATTACK_DAMAGE
	get_tree().current_scene.add_child(projectile)


func take_damage(damage: int, attacker_position: Vector2) -> void:
	health -= damage
	health_bar.update_health(health)

	if health <= 0:
		_die()
	else:
		take_damage_sound.play()
		_flash_red()
		_apply_knockback(attacker_position)
		# Hurt while the player is detected -> aggro-lock: no escape from now on.
		if is_instance_valid(target):
			is_provoked = true


func _flash_red() -> void:
	modulate = Color(1.5, 0.2, 0.2, 1.0)
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.25)


func _apply_knockback(attacker_position: Vector2) -> void:
	var knockback_dir = (global_position - attacker_position).normalized()
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
	AudioManager.clear_boss_music()
	AudioManager.play_sfx("boss_defeat")
	velocity = Vector2.ZERO

	$CollisionShape2D.set_deferred("disabled", true)
	$Sight/CollisionShape2D.set_deferred("disabled", true)
	$AttackHitbox/CollisionShape2D.set_deferred("disabled", true)

	died.emit()


func _on_sight_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		target = body
		if not _music_started:
			_music_started = true
			AudioManager.play_boss_music("boss_mushroom")


func _on_sight_body_exited(body: Node2D) -> void:
	if body.name == "Player" and is_alive:
		# A provoked mid-boss keeps chasing even after the player leaves the area.
		if is_provoked:
			return
		target = null
		is_target_in_attack_range = false
		if not _is_attacking:
			animated_sprite_2d.play("idle")


func _on_attack_hitbox_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		is_target_in_attack_range = true


func _on_attack_hitbox_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		is_target_in_attack_range = false
