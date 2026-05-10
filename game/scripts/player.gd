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
const MAX_HEALTH: int = 90

const BEER_SPEED_MULTIPLIER: float = 1.5
const BEER_EFFECT_DURATION: float = 10.0

# Tank regeneration: starts after this many seconds without taking damage,
# then refills at the given rates (per second).
const REGEN_DELAY: float = 2.5
const WATER_REGEN_PER_SEC: float = 18.0
const ACID_REGEN_PER_SEC: float = 12.0

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
var current_health: int = MAX_HEALTH
var input_locked: bool = false

var beer_count: int = 0
var _beer_effect_left: float = 0.0
var _beer_effect_active: bool = false
var _move_speed_multiplier: float = 1.0

# Time since the player last took damage. Tanks regen only after REGEN_DELAY.
var time_since_damage: float = 999.0
var _water_acc: float = 0.0
var _acid_acc: float = 0.0
var _water_depleted: bool = false


@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var swing_scissors: AudioStreamPlayer2D = $SwingScissors
@onready var hitbox: Area2D = $Hitbox


func _ready() -> void:
	# Initialise hitbox offset
	hitbox_offset = hitbox.position
	call_deferred("emit_initial_ui_state")


func emit_initial_ui_state() -> void:
	water_capacity_changed.emit(current_water_capacity, MAX_WATER_CAPACITY)
	shot_mode_changed.emit(int(shot_mode))
	acid_status_changed.emit(current_acid_capacity, MAX_ACID_CAPACITY, is_acid_cooling_down, acid_cooldown_left)
	health_changed.emit(current_health, MAX_HEALTH)
	beer_count_changed.emit(beer_count)
	beer_effect_active_changed.emit(false)
	beer_effect_time_left_changed.emit(0.0)


func _physics_process(_delta: float) -> void:
	_process_beer_effect(_delta)

	if current_health <= 0:
		velocity = Vector2.ZERO
		return

	if input_locked:
		velocity = Vector2.ZERO
		hitbox.monitoring = false
		play_animation("idle", last_direction)
		move_and_slide()
		return

	# Disable hitbox until an attack is triggered
	hitbox.monitoring = false

	if shot_cooldown_left > 0.0:
		shot_cooldown_left = max(shot_cooldown_left - _delta, 0.0)

	# Tank regeneration when not recently damaged
	time_since_damage += _delta
	_process_tank_regen(_delta)

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
		
	if is_attacking:
		velocity = Vector2.ZERO
		return
	
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
		velocity = direction * SPEED * _move_speed_multiplier
		last_direction = direction
		update_hitbox_offset()
	else:
		velocity = Vector2.ZERO
		

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
	if current_water_capacity <= 0:
		_water_depleted = true


func consume_acid(amount: int) -> void:
	current_acid_capacity = max(current_acid_capacity - amount, 0)

	if current_acid_capacity <= 0:
		start_acid_cooldown()
		return

	acid_status_changed.emit(current_acid_capacity, MAX_ACID_CAPACITY, false, 0.0)


func refill_water_tank() -> void:
	current_water_capacity = MAX_WATER_CAPACITY
	water_capacity_changed.emit(current_water_capacity, MAX_WATER_CAPACITY)


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
	swing_scissors.play()	
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
	if is_attacking and body.name.begins_with("Slime"):
		body.take_damage(strenght, position)


func _process_tank_regen(delta: float) -> void:
	if time_since_damage < REGEN_DELAY:
		_water_acc = 0.0
		return

	# Water tank regen only when it was fully depleted.
	# Keeps regenerating until it reaches max; then stops.
	if _water_depleted:
		_water_acc += WATER_REGEN_PER_SEC * delta
		var water_add := int(_water_acc)
		if water_add > 0:
			_water_acc -= float(water_add)
			current_water_capacity = min(current_water_capacity + water_add, MAX_WATER_CAPACITY)
			water_capacity_changed.emit(current_water_capacity, MAX_WATER_CAPACITY)
			if current_water_capacity >= MAX_WATER_CAPACITY:
				_water_depleted = false
				_water_acc = 0.0
	else:
		_water_acc = 0.0


func take_damage(damage: int) -> void:
	if current_health <= 0:
		return

	time_since_damage = 0.0
	current_health = max(current_health - damage, 0)
	health_changed.emit(current_health, MAX_HEALTH)

	if current_health <= 0:
		die()


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


func try_use_beer() -> void:
	if beer_count <= 0:
		return
	if _beer_effect_active:
		return

	beer_count = max(beer_count - 1, 0)
	beer_count_changed.emit(beer_count)

	_beer_effect_active = true
	_beer_effect_left = BEER_EFFECT_DURATION
	_move_speed_multiplier = BEER_SPEED_MULTIPLIER
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
	_move_speed_multiplier = 1.0
	beer_effect_active_changed.emit(false)
	beer_effect_time_left_changed.emit(0.0)
