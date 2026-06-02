extends CharacterBody2D


signal died


const PHASE2_HEALTH_THRESHOLD: int = 50

const PHASE1_SPEED: float = 125.0
const PHASE2_SPEED: float = 225.0

const KNOCKBACK_FORCE: float = 320.0

const MELEE_DAMAGE: int = 16
const MELEE_TRIGGER_RANGE: float = 85.0
const MELEE_WINDUP: float = 0.14
const MELEE_ACTIVE_TIME: float = 0.18
const MELEE_COOLDOWN: float = 0.95

const MEDIUM_DAMAGE: int = 12
const MEDIUM_TRIGGER_RANGE: float = 230.0
const MEDIUM_WINDUP: float = 0.22
const MEDIUM_ACTIVE_TIME: float = 0.22
const MEDIUM_COOLDOWN: float = 1.55

const RANGED_DAMAGE: int = 12
const RANGED_COOLDOWN_P1: float = 2.8
const RANGED_COOLDOWN_P2: float = 1.2

const COCONUT_SCENE: PackedScene = preload("res://scenes/coconut_projectile.tscn")

var is_alive: bool = true
var health: int = 100
var target: Node2D = null

var _phase2: bool = false
var _is_being_knocked_back: bool = false
var _is_attacking: bool = false

var _melee_cooldown_left: float = 0.0
var _medium_cooldown_left: float = 0.0
var _ranged_cooldown_left: float = 0.0

@onready var sprite: Sprite2D = $Sprite
@onready var take_damage_sound: AudioStreamPlayer2D = $TakeDamage
@onready var health_bar: Node2D = $HealthBar
@onready var sight: Area2D = $Sight
@onready var melee_hitbox: Area2D = $MeleeHitbox
@onready var medium_hitbox: Area2D = $MediumHitbox


func _ready() -> void:
	melee_hitbox.monitoring = false
	medium_hitbox.monitoring = false

	sight.body_entered.connect(_on_sight_body_entered)
	sight.body_exited.connect(_on_sight_body_exited)
	melee_hitbox.body_entered.connect(_on_melee_hitbox_body_entered)
	medium_hitbox.body_entered.connect(_on_medium_hitbox_body_entered)


func _physics_process(delta: float) -> void:
	_melee_cooldown_left = max(_melee_cooldown_left - delta, 0.0)
	_medium_cooldown_left = max(_medium_cooldown_left - delta, 0.0)
	_ranged_cooldown_left = max(_ranged_cooldown_left - delta, 0.0)

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
	var speed := PHASE2_SPEED if _phase2 else PHASE1_SPEED

	# Coconut ranged attack (both phases, faster in phase 2)
	if _ranged_cooldown_left <= 0.0 and distance > MELEE_TRIGGER_RANGE:
		_spawn_coconut()
		_ranged_cooldown_left = RANGED_COOLDOWN_P2 if _phase2 else RANGED_COOLDOWN_P1

	# Phase 1+2: melee and medium-range attacks.
	var direction := (target.global_position - global_position).normalized()

	if distance <= MELEE_TRIGGER_RANGE:
		if _melee_cooldown_left <= 0.0 and not _is_attacking:
			velocity = Vector2.ZERO
			_try_melee()
		elif _medium_cooldown_left <= 0.0 and not _is_attacking:
			velocity = Vector2.ZERO
			_try_medium()
		else:
			# Stay close but don't run through the player
			velocity = Vector2.ZERO
	elif distance <= MEDIUM_TRIGGER_RANGE:
		if _medium_cooldown_left <= 0.0 and not _is_attacking:
			velocity = Vector2.ZERO
			_try_medium()
		else:
			# Keep approaching while medium is on cooldown
			velocity = direction * speed
	else:
		velocity = direction * speed

	move_and_slide()


func _try_melee() -> void:
	if _is_attacking:
		return
	if _melee_cooldown_left > 0.0:
		return
	_melee_cooldown_left = MELEE_COOLDOWN
	_is_attacking = true
	_do_melee()


func _do_melee() -> void:
	# Windup: shake and turn red
	_anim_windup()
	await get_tree().create_timer(MELEE_WINDUP).timeout
	if not is_alive:
		_is_attacking = false
		return
	# Slam: flash white + spawn ground impact ring
	_anim_melee_slam()
	melee_hitbox.monitoring = true
	await get_tree().create_timer(MELEE_ACTIVE_TIME).timeout
	melee_hitbox.monitoring = false
	_is_attacking = false


func _try_medium() -> void:
	if _is_attacking:
		return
	if _medium_cooldown_left > 0.0:
		return
	_medium_cooldown_left = MEDIUM_COOLDOWN
	_is_attacking = true
	_do_medium()


func _do_medium() -> void:
	# Windup: shake
	_anim_windup()
	await get_tree().create_timer(MEDIUM_WINDUP).timeout
	if not is_alive:
		_is_attacking = false
		return
	# Leaf whip: green expanding ring
	_anim_leaf_whip()
	medium_hitbox.monitoring = true
	await get_tree().create_timer(MEDIUM_ACTIVE_TIME).timeout
	medium_hitbox.monitoring = false
	_is_attacking = false


func _spawn_coconut() -> void:
	if COCONUT_SCENE == null:
		return
	var coconut = COCONUT_SCENE.instantiate()
	if coconut == null:
		return

	var root := get_tree().current_scene
	if root != null:
		root.add_child(coconut)
	else:
		get_parent().add_child(coconut)

	# Spawn slightly offset from boss center so it clears the body
	var dir := (target.global_position - global_position).normalized()
	if dir == Vector2.ZERO:
		dir = Vector2.RIGHT
	coconut.global_position = global_position + dir * 50.0
	if coconut.has_method("setup"):
		coconut.setup(target, dir, RANGED_DAMAGE, self)


## ── Attack animation helpers ──────────────────────────────────────────

func _anim_windup() -> void:
	# Quick shake left-right during windup
	var orig_pos := sprite.position
	var tw := create_tween()
	tw.tween_property(sprite, "position", orig_pos + Vector2(-4, 0), 0.03)
	tw.tween_property(sprite, "position", orig_pos + Vector2(4, 0), 0.03)
	tw.tween_property(sprite, "position", orig_pos + Vector2(-3, 0), 0.03)
	tw.tween_property(sprite, "position", orig_pos, 0.03)
	# Tint slightly red during windup
	sprite.modulate = Color(1.3, 0.7, 0.7, 1.0)
	var color_tw := create_tween()
	color_tw.tween_property(sprite, "modulate", Color.WHITE, 0.15)


func _anim_melee_slam() -> void:
	# Flash white on impact
	sprite.modulate = Color(2.0, 2.0, 2.0, 1.0)
	var tw := create_tween()
	tw.tween_property(sprite, "modulate", Color.WHITE, 0.15)
	# Ground slam ring (red expanding circle)
	_spawn_impact_ring(Color(0.9, 0.2, 0.1, 0.7), MELEE_TRIGGER_RANGE)


func _anim_leaf_whip() -> void:
	# Flash green on leaf whip
	sprite.modulate = Color(0.5, 1.5, 0.5, 1.0)
	var tw := create_tween()
	tw.tween_property(sprite, "modulate", Color.WHITE, 0.2)
	# Leaf whip ring (green expanding circle)
	_spawn_impact_ring(Color(0.2, 0.8, 0.1, 0.6), MEDIUM_TRIGGER_RANGE)


func _spawn_impact_ring(color: Color, max_radius: float) -> void:
	# Create a visual ring that expands and fades out
	var ring := Node2D.new()
	ring.global_position = global_position
	ring.z_index = -1
	get_tree().current_scene.add_child(ring)

	var circle := Polygon2D.new()
	# Build circle polygon (16 segments)
	var points := PackedVector2Array()
	for i in range(16):
		var angle := i * TAU / 16.0
		points.append(Vector2(cos(angle), sin(angle)) * 8.0)
	circle.polygon = points
	circle.color = color
	ring.add_child(circle)

	# Animate: expand scale and fade out
	var tw := ring.create_tween()
	tw.set_parallel(true)
	tw.tween_property(ring, "scale", Vector2.ONE * (max_radius / 8.0), 0.25).set_ease(Tween.EASE_OUT)
	tw.tween_property(circle, "color:a", 0.0, 0.3)
	tw.set_parallel(false)
	tw.tween_callback(ring.queue_free)


func _on_melee_hitbox_body_entered(body: Node2D) -> void:
	if not is_alive or not melee_hitbox.monitoring:
		return
	if body == null:
		return
	if body.name != "Player":
		return
	if body.has_method("take_damage"):
		body.take_damage(MELEE_DAMAGE)


func _on_medium_hitbox_body_entered(body: Node2D) -> void:
	if not is_alive or not medium_hitbox.monitoring:
		return
	if body == null:
		return
	if body.name != "Player":
		return
	if body.has_method("take_damage"):
		body.take_damage(MEDIUM_DAMAGE)


func take_damage(damage: int, attacker_position: Vector2) -> void:
	if not is_alive:
		return

	health -= damage
	if health_bar != null and health_bar.has_method("update_health"):
		health_bar.update_health(health)

	if not _phase2 and health <= PHASE2_HEALTH_THRESHOLD:
		_phase2 = true
		# Visual feedback for phase 2
		sprite.modulate = Color(1.2, 0.75, 0.75, 1.0)

	if health <= 0:
		_die()
		return

	if take_damage_sound != null:
		take_damage_sound.play()
	_flash_red()
	_apply_knockback(attacker_position)


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
	melee_hitbox.monitoring = false
	medium_hitbox.monitoring = false

	$CollisionShape2D.set_deferred("disabled", true)
	$Sight/CollisionShape2D.set_deferred("disabled", true)
	$MeleeHitbox/CollisionShape2D.set_deferred("disabled", true)
	$MediumHitbox/CollisionShape2D.set_deferred("disabled", true)

	died.emit()

	var fade := create_tween()
	fade.tween_property(self, "modulate:a", 0.0, 0.8)
	fade.tween_callback(queue_free)


func _on_sight_body_entered(body: Node2D) -> void:
	if body != null and body.name == "Player":
		target = body


func _on_sight_body_exited(body: Node2D) -> void:
	if body != null and body.name == "Player" and is_alive:
		target = null
