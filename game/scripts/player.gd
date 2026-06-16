extends CharacterBody2D


const SPEED = 300.0
const PROJECTILE_SCENE: PackedScene = preload("res://scenes/projectile.tscn")
const SHOT_COOLDOWN: float = 0.2
const PROJECTILE_SPAWN_OFFSET: float = 28.0
const MAX_WATER_CAPACITY: int = 100
const WATER_SHOT_COST: int = 10
const MAX_ACID_CAPACITY: int = 100
const ACID_SHOT_COST: int = 10
const ACID_REFILL_COOLDOWN: float = 7.0
const HEALTH_PER_HEART: int = 30
const BASE_MAX_HEALTH: int = 3 * HEALTH_PER_HEART

const PIXEL_THEME: Theme = preload("res://assets/themes/pixel_theme.tres")

const BEER_SPEED_MULTIPLIER: float = 1.5
const BEER_EFFECT_DURATION: float = 10.0

const KNOCKBACK_FORCE: float = 320.0
const KNOCKBACK_TIME: float = 0.15
# Throttles the hurt feedback (flash + knockback) so repeated/continuous damage
# (e.g. the mushroom boss gas) neither strobes nor changes damage balance.
const HURT_FEEDBACK_COOLDOWN: float = 0.35

# Base reach of the scissors melee hitbox, multiplying the scene shape scale.
const BASE_SCISSORS_RANGE_MULTIPLIER: float = 1.25

enum ShotMode { WATER, ACID }

signal water_capacity_changed(current: int, max_capacity: int)
signal shot_mode_changed(mode: int)
signal acid_status_changed(current: int, max_capacity: int, is_cooling_down: bool, cooldown_left: float)
signal health_changed(current: int, max_health: int)

signal beer_count_changed(count: int)
signal beer_effect_active_changed(active: bool)
signal beer_effect_time_left_changed(time_left: float)


var last_direction: Vector2 = Vector2.RIGHT
var is_attacking: bool = false
var hitbox_offset: Vector2
var strenght: int = 20
var shot_mode: ShotMode = ShotMode.WATER
var shot_cooldown_left: float = 0.0
var is_target_lock_enabled: bool = false
var locked_target: Node2D = null
var current_water_capacity: int = MAX_WATER_CAPACITY
var current_acid_capacity: int = MAX_ACID_CAPACITY
var is_acid_cooling_down: bool = false
var acid_cooldown_left: float = 0.0
var max_health: int = BASE_MAX_HEALTH
var current_health: int = BASE_MAX_HEALTH
var input_locked: bool = false

var _is_knocked_back: bool = false
var _hurt_feedback_cd: float = 0.0
var _flash_tween: Tween = null

var beer_count: int = 0
var _beer_effect_left: float = 0.0
var _beer_effect_active: bool = false
var _beer_speed_multiplier: float = 1.0
var _slow_speed_multiplier: float = 1.0

var _sink_fill_left: float = 0.0
var _sink_fill_label: Label = null

var _hint_label: Label = null
var _hint_left: float = 0.0
var _out_of_water_cd: float = 0.0

var _base_hitbox_scale: Vector2 = Vector2.ONE


@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var _hitbox_collision_shape: CollisionShape2D = $Hitbox/CollisionShape2D


func _ready() -> void:
	# Initialise hitbox offset
	hitbox_offset = hitbox.position
	var scene_hitbox_scale := _hitbox_collision_shape.scale if _hitbox_collision_shape != null else Vector2.ONE
	_base_hitbox_scale = scene_hitbox_scale * BASE_SCISSORS_RANGE_MULTIPLIER
	_load_persistent_state()
	_apply_persistent_bonuses()
	_setup_sink_fill_label()
	_setup_hint_label()
	call_deferred("emit_initial_ui_state")


func _setup_hint_label() -> void:
	_hint_label = Label.new()
	_hint_label.theme = PIXEL_THEME
	_hint_label.visible = false
	_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_hint_label.custom_minimum_size = Vector2(300, 28)
	_hint_label.position = Vector2(-150, -188)
	_hint_label.z_index = 50
	add_child(_hint_label)


func _show_player_hint(text: String, duration: float) -> void:
	if _hint_label == null:
		return
	_hint_label.text = text
	_hint_label.visible = true
	_hint_left = duration


func _setup_sink_fill_label() -> void:
	_sink_fill_label = Label.new()
	_sink_fill_label.theme = PIXEL_THEME
	_sink_fill_label.visible = false
	_sink_fill_label.text = ""
	_sink_fill_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_sink_fill_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_sink_fill_label.custom_minimum_size = Vector2(260, 28)
	# Position in world space above the player.
	_sink_fill_label.position = Vector2(-130, -150)
	_sink_fill_label.z_index = 50
	add_child(_sink_fill_label)


func emit_initial_ui_state() -> void:
	water_capacity_changed.emit(current_water_capacity, MAX_WATER_CAPACITY)
	shot_mode_changed.emit(int(shot_mode))
	acid_status_changed.emit(current_acid_capacity, MAX_ACID_CAPACITY, is_acid_cooling_down, acid_cooldown_left)
	health_changed.emit(current_health, max_health)
	beer_count_changed.emit(beer_count)
	beer_effect_active_changed.emit(false)
	beer_effect_time_left_changed.emit(0.0)


func _physics_process(_delta: float) -> void:
	_process_sink_fill_feedback(_delta)
	_process_beer_effect(_delta)
	_process_hint(_delta)

	if current_health <= 0:
		velocity = Vector2.ZERO
		return

	if _hurt_feedback_cd > 0.0:
		_hurt_feedback_cd = max(_hurt_feedback_cd - _delta, 0.0)

	# While being knocked back, ignore input and just slide with the impulse.
	if _is_knocked_back:
		hitbox.monitoring = false
		move_and_slide()
		return

	if input_locked:
		velocity = Vector2.ZERO
		hitbox.monitoring = false
		play_animation("idle", last_direction)
		move_and_slide()
		return

	# The scissors hitbox is active for the whole swing (the player can keep
	# moving during it), and off otherwise.
	hitbox.monitoring = is_attacking

	if shot_cooldown_left > 0.0:
		shot_cooldown_left = max(shot_cooldown_left - _delta, 0.0)

	if is_acid_cooling_down:
		acid_cooldown_left = max(acid_cooldown_left - _delta, 0.0)
		acid_status_changed.emit(current_acid_capacity, MAX_ACID_CAPACITY, true, acid_cooldown_left)

		if acid_cooldown_left <= 0.0:
			finish_acid_cooldown()

	if Input.is_action_just_pressed("toggle_shot_mode"):
		toggle_shot_mode()

	if Input.is_action_just_pressed("toggle_target_lock"):
		toggle_target_lock()

	if is_target_lock_enabled and not is_instance_valid(locked_target):
		disable_target_lock()

	if Input.is_action_just_pressed("use_beer"):
		try_use_beer()

	if Input.is_action_pressed("shoot"):
		try_shoot()
	
	
	if Input.is_action_just_pressed("attack") and not is_attacking:
		attack()

	# The player can walk and swing the scissors at the same time — no stop.
	process_movement()
	process_animaion()
	move_and_slide()


# ---------------------------------------------------------------
# MOVEMENT & ANIMATION
# ---------------------------------------------------------------

func process_movement() -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, yo	u should replace UI actions with custom gameplay actions.
	var direction := Input.get_vector("left", "right", "up", "down")
	
	if direction != Vector2.ZERO:
		velocity = direction * SPEED * _get_speed_multiplier()
		last_direction = direction
		update_hitbox_offset()
	else:
		velocity = Vector2.ZERO


func _get_speed_multiplier() -> float:
	return _beer_speed_multiplier * _slow_speed_multiplier


func set_slow_multiplier(multiplier: float) -> void:
	_slow_speed_multiplier = clampf(multiplier, 0.1, 1.0)


func clear_slow_multiplier() -> void:
	_slow_speed_multiplier = 1.0
		

func process_animaion() -> void:
	if is_attacking:
		return
	if velocity != Vector2.ZERO:
		play_animation("run", last_direction)
	else:
		play_animation("idle", last_direction)


func play_animation(prefix: String, dir: Vector2) -> void:
	if dir.x != 0:
		animated_sprite_2d.flip_h = dir.x < 0
		animated_sprite_2d.play(prefix + "_right")
	elif dir.y < 0:
		animated_sprite_2d.play(prefix + "_up")
	elif dir.y > 0:
		animated_sprite_2d.play(prefix + "_down")


# ---------------------------------------------------------------
# SHOOTING
# ---------------------------------------------------------------

func toggle_shot_mode() -> void:
	if shot_mode == ShotMode.WATER:
		shot_mode = ShotMode.ACID
	else:
		shot_mode = ShotMode.WATER

	shot_mode_changed.emit(int(shot_mode))


func try_shoot() -> void:
	if shot_cooldown_left > 0.0:
		return

	if shot_mode == ShotMode.WATER and current_water_capacity < WATER_SHOT_COST:
		# Diagnostic feedback (Nielsen H9): tell the player why nothing happened.
		if _out_of_water_cd <= 0.0:
			_show_player_hint("Brak wody!\nUzupełnij przy zgrzewce", 2.0)
			_out_of_water_cd = 2.5
		return

	if shot_mode == ShotMode.ACID:
		if is_acid_cooling_down:
			return

		if current_acid_capacity < ACID_SHOT_COST:
			start_acid_cooldown()
			return

	var direction := get_shoot_direction()
	if direction == Vector2.ZERO:
		direction = last_direction.normalized()

	spawn_projectile(direction)
	AudioManager.play_sfx("shoot_water" if shot_mode == ShotMode.WATER else "shoot_acid")

	if shot_mode == ShotMode.WATER:
		consume_water(WATER_SHOT_COST)
	elif shot_mode == ShotMode.ACID:
		consume_acid(ACID_SHOT_COST)

	shot_cooldown_left = SHOT_COOLDOWN


func spawn_projectile(direction: Vector2) -> void:
	var projectile = PROJECTILE_SCENE.instantiate()
	if projectile == null:
		return

	var root = get_tree().current_scene
	var spawn_position := global_position + direction * PROJECTILE_SPAWN_OFFSET

	if root:
		root.add_child(projectile)
	else:
		get_parent().add_child(projectile)

	projectile.global_position = spawn_position
	projectile.setup(direction, int(shot_mode), strenght)


func consume_water(amount: int) -> void:
	current_water_capacity = max(current_water_capacity - amount, 0)
	water_capacity_changed.emit(current_water_capacity, MAX_WATER_CAPACITY)


func consume_acid(amount: int) -> void:
	current_acid_capacity = max(current_acid_capacity - amount, 0)

	if current_acid_capacity <= 0:
		start_acid_cooldown()
		return

	acid_status_changed.emit(current_acid_capacity, MAX_ACID_CAPACITY, false, 0.0)


func refill_water_tank() -> void:
	current_water_capacity = MAX_WATER_CAPACITY
	water_capacity_changed.emit(current_water_capacity, MAX_WATER_CAPACITY)


func refill_water(amount: int) -> bool:
	if amount <= 0:
		return false

	var before := current_water_capacity
	current_water_capacity = clampi(current_water_capacity + amount, 0, MAX_WATER_CAPACITY)
	if current_water_capacity == before:
		return false

	water_capacity_changed.emit(current_water_capacity, MAX_WATER_CAPACITY)
	return true


func start_sink_fill_feedback(duration: float) -> void:
	_sink_fill_left = maxf(duration, 0.0)
	_update_sink_fill_label()
	if _sink_fill_label != null:
		_sink_fill_label.visible = _sink_fill_left > 0.0


func _process_hint(delta: float) -> void:
	if _out_of_water_cd > 0.0:
		_out_of_water_cd = maxf(_out_of_water_cd - delta, 0.0)
	if _hint_left > 0.0:
		_hint_left = maxf(_hint_left - delta, 0.0)
		if _hint_left <= 0.0 and _hint_label != null:
			_hint_label.visible = false


func _process_sink_fill_feedback(delta: float) -> void:
	if _sink_fill_left <= 0.0:
		return

	_sink_fill_left = maxf(_sink_fill_left - delta, 0.0)
	_update_sink_fill_label()
	if _sink_fill_left <= 0.0 and _sink_fill_label != null:
		_sink_fill_label.visible = false


func _update_sink_fill_label() -> void:
	if _sink_fill_label == null:
		return
	if _sink_fill_left <= 0.0:
		_sink_fill_label.text = ""
		return

	_sink_fill_label.text = "Napełnianie: %.1fs" % _sink_fill_left


func start_acid_cooldown() -> void:
	if is_acid_cooling_down:
		return

	is_acid_cooling_down = true
	acid_cooldown_left = ACID_REFILL_COOLDOWN
	acid_status_changed.emit(current_acid_capacity, MAX_ACID_CAPACITY, true, acid_cooldown_left)


func finish_acid_cooldown() -> void:
	is_acid_cooling_down = false
	acid_cooldown_left = 0.0
	current_acid_capacity = MAX_ACID_CAPACITY
	acid_status_changed.emit(current_acid_capacity, MAX_ACID_CAPACITY, false, acid_cooldown_left)


func get_shoot_direction() -> Vector2:
	if is_target_lock_enabled and is_instance_valid(locked_target):
		return (locked_target.global_position - global_position).normalized()

	return (get_global_mouse_position() - global_position).normalized()


func toggle_target_lock() -> void:
	if is_target_lock_enabled:
		disable_target_lock()
		return

	var target := get_enemy_under_mouse()
	if target:
		locked_target = target
		is_target_lock_enabled = true
		_bind_locked_target_signals()


func disable_target_lock() -> void:
	_unbind_locked_target_signals()
	is_target_lock_enabled = false
	locked_target = null


func _bind_locked_target_signals() -> void:
	if not is_instance_valid(locked_target):
		return

	var died_cb := Callable(self, "_on_locked_target_died")
	if locked_target.has_signal("died") and not locked_target.is_connected("died", died_cb):
		locked_target.connect("died", died_cb)


func _unbind_locked_target_signals() -> void:
	if not is_instance_valid(locked_target):
		return

	var died_cb := Callable(self, "_on_locked_target_died")
	if locked_target.has_signal("died") and locked_target.is_connected("died", died_cb):
		locked_target.disconnect("died", died_cb)


func _on_locked_target_died() -> void:
	# Enemy can stay in the scene (death animation/corpse), but lock-on should end.
	disable_target_lock()


func get_enemy_under_mouse() -> Node2D:
	var point_query := PhysicsPointQueryParameters2D.new()
	point_query.position = get_global_mouse_position()
	point_query.collision_mask = 2
	point_query.collide_with_bodies = true
	point_query.collide_with_areas = false

	var results := get_world_2d().direct_space_state.intersect_point(point_query, 8)
	for result in results:
		var collider = result.get("collider")
		if collider is Node2D and collider.has_method("take_damage"):
			return collider

	return null


# ---------------------------------------------------------------
# ATTACKING
# ---------------------------------------------------------------

func attack() -> void:
	is_attacking = true
	hitbox.monitoring = true
	AudioManager.play_sfx("melee")
	play_animation("attack", last_direction)


func _on_animated_sprite_2d_animation_finished() -> void:
	if is_attacking:
		is_attacking = false


# ---------------------------------------------------------------
# HITBOX
# ---------------------------------------------------------------

func update_hitbox_offset() -> void:
	var x := hitbox_offset.x
	var y := hitbox_offset.y
	
	match last_direction:
		Vector2.LEFT:
			hitbox.position = Vector2(-x, y)
		Vector2.RIGHT:
			hitbox.position = Vector2(x, y)
		Vector2.UP:
			hitbox.position = Vector2(y, -x)
		Vector2.DOWN:
			hitbox.position = Vector2(-y, x)


func _on_hitbox_body_entered(body: Node2D) -> void:
	if not is_attacking:
		return
	if body != null and body.has_method("take_damage"):
		body.take_damage(strenght, position)


func take_damage(damage: int, attacker_position: Vector2 = Vector2.ZERO) -> void:
	if current_health <= 0:
		return
	current_health = max(current_health - damage, 0)
	health_changed.emit(current_health, max_health)
	_save_persistent_health()

	if current_health <= 0:
		die()
		return

	# Visual/physical hit feedback, throttled so continuous damage doesn't strobe.
	if _hurt_feedback_cd <= 0.0:
		_flash_red()
		AudioManager.play_sfx("player_hurt")
		if attacker_position != Vector2.ZERO:
			_apply_knockback(attacker_position)
		_hurt_feedback_cd = HURT_FEEDBACK_COOLDOWN


func _flash_red() -> void:
	# Very pronounced red flash held for ~1s, to clearly signal taking damage.
	if _flash_tween and _flash_tween.is_valid():
		_flash_tween.kill()
	animated_sprite_2d.modulate = Color(3.0, 0.0, 0.0, 1.0)
	_flash_tween = create_tween()
	_flash_tween.tween_interval(0.55)
	_flash_tween.tween_property(animated_sprite_2d, "modulate", Color.WHITE, 0.45)


func _apply_knockback(attacker_position: Vector2) -> void:
	var knockback_dir := (global_position - attacker_position)
	if knockback_dir == Vector2.ZERO:
		knockback_dir = -last_direction
	knockback_dir = knockback_dir.normalized()

	_is_knocked_back = true
	is_attacking = false
	velocity = knockback_dir * KNOCKBACK_FORCE

	var tween := create_tween()
	tween.tween_interval(KNOCKBACK_TIME)
	tween.tween_callback(func() -> void:
		_is_knocked_back = false
		velocity = Vector2.ZERO
	)


func die() -> void:
	is_attacking = false
	velocity = Vector2.ZERO
	hitbox.monitoring = false
	$CollisionShape2D.set_deferred("disabled", true)
	$Hitbox/CollisionShape2D.set_deferred("disabled", true)
	animated_sprite_2d.play("dying")


func add_beer(amount: int) -> void:
	if amount <= 0:
		return
	beer_count += amount
	beer_count_changed.emit(beer_count)
	_save_persistent_beer()


func try_use_beer() -> void:
	if beer_count <= 0:
		return
	if _beer_effect_active:
		return

	beer_count = max(beer_count - 1, 0)
	beer_count_changed.emit(beer_count)
	_save_persistent_beer()
	AudioManager.play_sfx("beer_drink")

	_beer_effect_active = true
	_beer_effect_left = BEER_EFFECT_DURATION
	_beer_speed_multiplier = BEER_SPEED_MULTIPLIER
	beer_effect_active_changed.emit(true)
	beer_effect_time_left_changed.emit(_beer_effect_left)


func _process_beer_effect(delta: float) -> void:
	if not _beer_effect_active:
		return

	_beer_effect_left = max(_beer_effect_left - delta, 0.0)
	beer_effect_time_left_changed.emit(_beer_effect_left)
	if _beer_effect_left > 0.0:
		return

	_beer_effect_active = false
	_beer_speed_multiplier = 1.0
	beer_effect_active_changed.emit(false)
	beer_effect_time_left_changed.emit(0.0)


func heal(amount: int) -> bool:
	if amount <= 0:
		return false
	if current_health <= 0:
		return false

	var before := current_health
	current_health = clampi(current_health + amount, 0, max_health)
	if current_health == before:
		return false

	health_changed.emit(current_health, max_health)
	_save_persistent_health()
	return true


func heal_one_heart() -> bool:
	return heal(HEALTH_PER_HEART)


# Full reset of combat resources — health, water and acid back to max.
# Used on the foyer -> level 1 transition to wipe any tutorial-test damage.
func restore_full_stats() -> void:
	max_health = maxi(max_health, 1)
	current_health = max_health
	current_water_capacity = MAX_WATER_CAPACITY
	current_acid_capacity = MAX_ACID_CAPACITY
	is_acid_cooling_down = false
	acid_cooldown_left = 0.0

	health_changed.emit(current_health, max_health)
	water_capacity_changed.emit(current_water_capacity, MAX_WATER_CAPACITY)
	acid_status_changed.emit(current_acid_capacity, MAX_ACID_CAPACITY, false, 0.0)
	_save_persistent_health()


func sync_from_game_state() -> void:
	var gs := _get_game_state()
	if gs == null:
		return

	beer_count = gs.beer_count
	max_health = maxi(gs.max_health, 1)
	current_health = clampi(gs.current_health, 0, max_health)

	beer_count_changed.emit(beer_count)
	health_changed.emit(current_health, max_health)
	_apply_persistent_bonuses()


func apply_scissors_range_multiplier(multiplier: float) -> void:
	if _hitbox_collision_shape == null:
		return

	_hitbox_collision_shape.scale = _base_hitbox_scale * multiplier


func _get_game_state() -> Node:
	return get_node_or_null("/root/GameState")


func _load_persistent_state() -> void:
	var gs := _get_game_state()
	if gs == null:
		return

	beer_count = gs.beer_count
	max_health = maxi(gs.max_health, 1)
	current_health = clampi(gs.current_health, 0, max_health)

	if gs.has_method("consume_restart_state"):
		var restart_data: Dictionary = gs.call("consume_restart_state")
		if restart_data.has("water"):
			current_water_capacity = clampi(int(restart_data["water"]), 0, MAX_WATER_CAPACITY)
		if restart_data.has("acid"):
			current_acid_capacity = clampi(int(restart_data["acid"]), 0, MAX_ACID_CAPACITY)
			is_acid_cooling_down = false
			acid_cooldown_left = 0.0


func _save_persistent_health() -> void:
	var gs := _get_game_state()
	if gs == null:
		return
	gs.set_health(current_health, max_health)


func _save_persistent_beer() -> void:
	var gs := _get_game_state()
	if gs == null:
		return
	gs.set_beer_count(beer_count)


func _apply_persistent_bonuses() -> void:
	var gs := _get_game_state()
	if gs == null:
		return
	apply_scissors_range_multiplier(gs.get_scissors_range_multiplier())
