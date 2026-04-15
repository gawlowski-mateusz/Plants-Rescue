extends Control


@onready var play_button: Button = %PlayButton
@onready var title: Label = %Title
@onready var press_hint: Label = %PressHint
@onready var cactus: AnimatedSprite2D = $Cactus


# Cactus wanders between these X positions at the bottom of the menu.
const CACTUS_LEFT_X: float = 430.0
const CACTUS_RIGHT_X: float = 900.0
const CACTUS_Y: float = 480.0
const CACTUS_SPEED: float = 110.0  # pixels / sec

var _cactus_dir: int = -1  # -1 going left, 1 going right
var _cactus_attacking: bool = false
var _attack_timer: float = 0.0


func _ready() -> void:
	play_button.pressed.connect(_start_game)

	# Subtle title pulse
	var t := create_tween().set_loops()
	t.tween_property(title, "modulate", Color(0.6, 1.0, 0.5, 1.0), 1.4)
	t.tween_property(title, "modulate", Color(1.0, 1.0, 0.7, 1.0), 1.4)

	# Hint blink
	var t2 := create_tween().set_loops()
	t2.tween_property(press_hint, "modulate:a", 0.25, 0.7)
	t2.tween_property(press_hint, "modulate:a", 1.0, 0.7)

	# Cactus starts on the right walking left
	cactus.position = Vector2(CACTUS_RIGHT_X, CACTUS_Y)
	cactus.flip_h = true  # face left
	cactus.play("walk")
	cactus.animation_finished.connect(_on_cactus_anim_finished)


func _process(delta: float) -> void:
	if _cactus_attacking:
		return

	# Walk
	cactus.position.x += _cactus_dir * CACTUS_SPEED * delta

	# Turn around at edges
	if cactus.position.x <= CACTUS_LEFT_X:
		cactus.position.x = CACTUS_LEFT_X
		_cactus_dir = 1
		cactus.flip_h = false  # face right
	elif cactus.position.x >= CACTUS_RIGHT_X:
		cactus.position.x = CACTUS_RIGHT_X
		_cactus_dir = -1
		cactus.flip_h = true  # face left

	# Every few seconds, pounce attack
	_attack_timer += delta
	if _attack_timer > 3.5:
		_attack_timer = 0.0
		_start_attack()


func _start_attack() -> void:
	_cactus_attacking = true
	cactus.play("attack")
	# Small pounce visual via scale pulse
	var t := create_tween()
	t.tween_property(cactus, "scale", Vector2(3.8, 3.8), 0.12)
	t.tween_property(cactus, "scale", Vector2(3.2, 3.2), 0.18)


func _on_cactus_anim_finished() -> void:
	if cactus.animation == "attack":
		_cactus_attacking = false
		cactus.play("walk")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		_start_game()


func _start_game() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")
