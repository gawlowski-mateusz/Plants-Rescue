extends Node2D


enum State { LETTER, FOYER, TRANSITION, GAME_OVER }


@onready var player: CharacterBody2D = $Player
@onready var door1: Door = $Doors/Door1
@onready var ui_layer: CanvasLayer = $UI

@onready var letter_overlay: CanvasLayer = $Overlays/LetterOverlay
@onready var letter_continue: Button = $Overlays/LetterOverlay/Panel/VBox/ContinueBtn
@onready var tutorial_toast: CanvasLayer = $Overlays/TutorialToast
@onready var toast_label: Label = $Overlays/TutorialToast/Panel/Label
@onready var toast_panel: Control = $Overlays/TutorialToast/Panel
@onready var game_over_screen: CanvasLayer = $Overlays/GameOverScreen
@onready var game_over_restart_btn: Button = $Overlays/GameOverScreen/Panel/VBox/RestartBtn
@onready var game_over_menu_btn: Button = $Overlays/GameOverScreen/Panel/VBox/MenuBtn

var state: int = State.LETTER
var _tutorial_tween: Tween = null
var _tutorial_queue: Array = []
var _tutorial_playing: bool = false


func _ready() -> void:
	tutorial_toast.visible = false
	game_over_screen.visible = false
	letter_overlay.visible = true

	# Hide the in-game HUD while the letter is on screen
	ui_layer.visible = false

	player.input_locked = true

	letter_continue.pressed.connect(_on_letter_continue)
	game_over_restart_btn.pressed.connect(_restart_scene)
	game_over_menu_btn.pressed.connect(_return_to_menu)

	door1.interacted.connect(_on_door_interacted)
	door1.opened.connect(_on_door_opened)

	player.health_changed.connect(_on_player_health_changed)


# ---------------------------------------------------------------
# LETTER / INTRO
# ---------------------------------------------------------------

func _on_letter_continue() -> void:
	letter_overlay.visible = false
	ui_layer.visible = true
	player.input_locked = false
	state = State.FOYER

	# Queue of tutorial toasts shown one after the other
	_queue_tutorial("WASD — ruch", 3.0)
	_queue_tutorial("Znajdź drzwi po prawej\ni wciśnij SPACJA lub E aby je otworzyć", 4.5)


# ---------------------------------------------------------------
# DOORS
# ---------------------------------------------------------------

func _on_door_interacted(door_id: String) -> void:
	if door_id != "door1":
		return
	if state != State.FOYER:
		return
	state = State.TRANSITION
	player.input_locked = true
	door1.open()


func _on_door_opened(_door_id: String) -> void:
	# Brief pause to let the animation read, then swap scenes
	await get_tree().create_timer(0.35).timeout
	get_tree().change_scene_to_file("res://scenes/living_room.tscn")


# ---------------------------------------------------------------
# HEALTH / GAME OVER
# ---------------------------------------------------------------

func _on_player_health_changed(current: int, _max_health: int) -> void:
	if current <= 0 and state != State.GAME_OVER:
		state = State.GAME_OVER
		await get_tree().create_timer(1.2).timeout
		game_over_screen.visible = true


# ---------------------------------------------------------------
# TUTORIAL TOASTS
# ---------------------------------------------------------------

func _queue_tutorial(text: String, duration: float) -> void:
	_tutorial_queue.append({"text": text, "duration": duration})
	if not _tutorial_playing:
		_play_next_tutorial()


func _play_next_tutorial() -> void:
	if _tutorial_queue.is_empty():
		_tutorial_playing = false
		tutorial_toast.visible = false
		return
	_tutorial_playing = true
	var entry = _tutorial_queue.pop_front()
	toast_label.text = entry["text"]
	tutorial_toast.visible = true
	toast_panel.modulate.a = 0.0
	if _tutorial_tween and _tutorial_tween.is_valid():
		_tutorial_tween.kill()
	_tutorial_tween = create_tween()
	_tutorial_tween.tween_property(toast_panel, "modulate:a", 1.0, 0.3)
	_tutorial_tween.tween_interval(entry["duration"])
	_tutorial_tween.tween_property(toast_panel, "modulate:a", 0.0, 0.4)
	_tutorial_tween.tween_callback(_play_next_tutorial)


# ---------------------------------------------------------------
# NAV
# ---------------------------------------------------------------

func _restart_scene() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _return_to_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
