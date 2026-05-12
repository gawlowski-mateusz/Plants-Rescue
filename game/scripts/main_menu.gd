extends Control


@onready var play_button: Button = %PlayButton
@onready var level_select_button: Button = %LevelSelectButton
@onready var quit_button: Button = %QuitButton
@onready var title: Label = %Title
@onready var press_hint: Label = %PressHint
@onready var cactus: AnimatedSprite2D = $Cactus

@onready var level_select_overlay: Control = %LevelSelectOverlay
@onready var level1_btn: Button = %Level1Btn
@onready var level2_btn: Button = %Level2Btn
@onready var level3_btn: Button = %Level3Btn
@onready var level4_btn: Button = %Level4Btn
@onready var back_btn: Button = %BackBtn

@onready var completion_toast: PanelContainer = %CompletionToast
@onready var completion_label: Label = $CompletionToast/Label


const CACTUS_LEFT_X: float = 430.0
const CACTUS_RIGHT_X: float = 900.0
const CACTUS_Y: float = 480.0
const CACTUS_SPEED: float = 110.0

const LEVEL_PATHS: Array = [
	"res://scenes/living_room.tscn",
	"res://scenes/kitchen.tscn",
	"res://scenes/bedroom.tscn",
	"res://scenes/balcony.tscn",
]

const LEVEL_NAMES: Array = [
	"Salon",
	"Kuchnia",
	"Sypialnia",
	"Pokój gamingowy",
]


var _cactus_dir: int = -1
var _cactus_attacking: bool = false
var _attack_timer: float = 0.0
var _toast_tween: Tween = null


func _ready() -> void:
	play_button.pressed.connect(_start_new_game)
	level_select_button.pressed.connect(_open_level_select)
	quit_button.pressed.connect(_quit_game)

	level1_btn.pressed.connect(_play_level.bind(0))
	level2_btn.pressed.connect(_play_level.bind(1))
	level3_btn.pressed.connect(_play_level.bind(2))
	level4_btn.pressed.connect(_play_level.bind(3))
	back_btn.pressed.connect(_close_level_select)

	level_select_overlay.visible = false
	completion_toast.visible = false

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
	cactus.flip_h = true
	cactus.play("walk")
	cactus.animation_finished.connect(_on_cactus_anim_finished)

	_show_pending_completion_message()


func _process(delta: float) -> void:
	if _cactus_attacking:
		return

	cactus.position.x += _cactus_dir * CACTUS_SPEED * delta

	if cactus.position.x <= CACTUS_LEFT_X:
		cactus.position.x = CACTUS_LEFT_X
		_cactus_dir = 1
		cactus.flip_h = false
	elif cactus.position.x >= CACTUS_RIGHT_X:
		cactus.position.x = CACTUS_RIGHT_X
		_cactus_dir = -1
		cactus.flip_h = true

	_attack_timer += delta
	if _attack_timer > 3.5:
		_attack_timer = 0.0
		_start_attack()


func _start_attack() -> void:
	_cactus_attacking = true
	cactus.play("attack")
	var t := create_tween()
	t.tween_property(cactus, "scale", Vector2(3.8, 3.8), 0.12)
	t.tween_property(cactus, "scale", Vector2(3.2, 3.2), 0.18)


func _on_cactus_anim_finished() -> void:
	if cactus.animation == "attack":
		_cactus_attacking = false
		cactus.play("walk")


func _unhandled_input(event: InputEvent) -> void:
	if level_select_overlay.visible:
		if event.is_action_pressed("ui_cancel"):
			_close_level_select()
			get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		_start_new_game()


# ---------------------------------------------------------------
# NEW GAME / LEVEL SELECT / QUIT
# ---------------------------------------------------------------

func _start_new_game() -> void:
	var gs := get_node_or_null("/root/GameState")
	if gs != null and gs.has_method("reset_run"):
		gs.reset_run()
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _open_level_select() -> void:
	level_select_overlay.visible = true


func _close_level_select() -> void:
	level_select_overlay.visible = false


func _play_level(index: int) -> void:
	if index < 0 or index >= LEVEL_PATHS.size():
		return

	var gs := get_node_or_null("/root/GameState")
	if gs != null and gs.has_method("reset_run"):
		gs.reset_run()
	if gs != null and gs.has_method("enter_single_level_mode"):
		gs.call("enter_single_level_mode")

	get_tree().change_scene_to_file(LEVEL_PATHS[index])


func _quit_game() -> void:
	get_tree().quit()


# ---------------------------------------------------------------
# COMPLETION TOAST
# ---------------------------------------------------------------

func _show_pending_completion_message() -> void:
	var gs := get_node_or_null("/root/GameState")
	if gs == null:
		return
	if not gs.has_method("consume_completion_message"):
		return

	var msg: String = String(gs.call("consume_completion_message"))
	if msg.strip_edges() == "":
		return

	completion_label.text = msg
	completion_toast.visible = true
	completion_toast.modulate.a = 0.0

	if _toast_tween and _toast_tween.is_valid():
		_toast_tween.kill()
	_toast_tween = create_tween()
	_toast_tween.tween_property(completion_toast, "modulate:a", 1.0, 0.4)
	_toast_tween.tween_interval(4.0)
	_toast_tween.tween_property(completion_toast, "modulate:a", 0.0, 0.6)
	_toast_tween.tween_callback(_hide_completion_toast)


func _hide_completion_toast() -> void:
	completion_toast.visible = false
