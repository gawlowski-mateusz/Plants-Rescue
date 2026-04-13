extends CharacterBody2D


const SPEED = 300.0
const PROJECTILE_SCENE: PackedScene = preload("res://scenes/projectile.tscn")
const SHOT_COOLDOWN: float = 0.2
const PROJECTILE_SPAWN_OFFSET: float = 28.0
const MAX_WATER_CAPACITY: int = 100
const WATER_SHOT_COST: int = 10

enum ShotMode { WATER, ACID }

signal water_capacity_changed(current: int, max_capacity: int)
signal shot_mode_changed(mode: int)


var last_direction: Vector2 = Vector2.RIGHT
var is_attacking: bool = false
var hitbox_offset: Vector2
var strenght: int = 20
var shot_mode: ShotMode = ShotMode.WATER
var shot_cooldown_left: float = 0.0
var is_target_lock_enabled: bool = false
var locked_target: Node2D = null
var current_water_capacity: int = MAX_WATER_CAPACITY


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


func _physics_process(_delta: float) -> void:
	# Disable hitbox until an attack is triggered
	hitbox.monitoring = false

	if shot_cooldown_left > 0.0:
		shot_cooldown_left = max(shot_cooldown_left - _delta, 0.0)

	if Input.is_action_just_pressed("toggle_shot_mode"):
		toggle_shot_mode()

	if Input.is_action_just_pressed("toggle_target_lock"):
		toggle_target_lock()

	if is_target_lock_enabled and not is_instance_valid(locked_target):
		disable_target_lock()

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
		velocity = direction * SPEED
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

	var direction := get_shoot_direction()
	if direction == Vector2.ZERO:
		direction = last_direction.normalized()

	spawn_projectile(direction)

	if shot_mode == ShotMode.WATER:
		consume_water(WATER_SHOT_COST)

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


func refill_water_tank() -> void:
	current_water_capacity = MAX_WATER_CAPACITY
	water_capacity_changed.emit(current_water_capacity, MAX_WATER_CAPACITY)


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


func disable_target_lock() -> void:
	is_target_lock_enabled = false
	locked_target = null


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
