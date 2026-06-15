extends Node2D


enum State { LETTER, FOYER, TRANSITION, GAME_OVER }


const SETTINGS_OVERLAY_SCENE: PackedScene = preload("res://scenes/settings_overlay.tscn")


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
var _settings_overlay: CanvasLayer = null


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

	AudioManager.play_music("gameplay_theme")

	_settings_overlay = SETTINGS_OVERLAY_SCENE.instantiate()
	$Overlays.add_child(_settings_overlay)


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):
		return
	# Pause menu only while exploring the foyer (not during the letter/game over).
	if state != State.FOYER:
		return
	if _settings_overlay == null or not _settings_overlay.has_method("open"):
		return
	if _settings_overlay.has_method("is_open") and bool(_settings_overlay.call("is_open")):
		return
	_settings_overlay.call("open", true)
	get_viewport().set_input_as_handled()


# ---------------------------------------------------------------
# LETTER / INTRO
# ---------------------------------------------------------------

func _on_letter_continue() -> void:
	letter_overlay.visible = false
	ui_layer.visible = true
	player.input_locked = false
	state = State.FOYER

	# The exit door stays locked until every tutorial message has been shown
	# (see _on_tutorials_finished). These describe all of the game mechanics.
	_queue_tutorial("WASD — poruszanie się", 3.0)
	_queue_tutorial("Lewy przycisk myszy — atak nożyczkami\n(walka wręcz z wrogami)", 4.0)
	_queue_tutorial("Prawy przycisk myszy — strzelanie\nPodlewaj wodą przyjazne rośliny, aby je uratować", 5.0)
	_queue_tutorial("X — przełącz między wodą a kwasem\nKwasem ranisz wrogie rośliny", 4.5)
	_queue_tutorial("Środkowy przycisk myszy — auto-celowanie\nnamierza wroga pod kursorem", 4.5)
	_queue_tutorial("Q — wypij piwo z lodówki\nDaje chwilowe przyspieszenie", 4.0)
	_queue_tutorial("Apteczka leczy, a zgrzewka uzupełnia wodę\n— wystarczy do nich podejść", 4.5)
	_queue_tutorial("SPACJA lub E — interakcja\n(drzwi, lodówka)", 3.5)


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
	# Level 1 should start fresh (full water/acid/health) and skip the onboarding
	# toasts, since the foyer already explained every mechanic.
	var gs := get_node_or_null("/root/GameState")
	if gs != null and gs.has_method("request_full_restore_on_next_level"):
		gs.call("request_full_restore_on_next_level")
	get_tree().change_scene_to_file("res://scenes/living_room.tscn")


# ---------------------------------------------------------------
# HEALTH / GAME OVER
# ---------------------------------------------------------------

func _on_player_health_changed(current: int, _max_health: int) -> void:
	if current <= 0 and state != State.GAME_OVER:
		state = State.GAME_OVER
		AudioManager.stop_music()
		AudioManager.play_sfx("game_over")
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
		_on_tutorials_finished()
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


func _on_tutorials_finished() -> void:
	# All mechanics explained -> open the way out.
	if door1.is_locked:
		door1.unlock()

	# Leave a persistent prompt on screen telling the player where to go.
	if _tutorial_tween and _tutorial_tween.is_valid():
		_tutorial_tween.kill()
	toast_label.text = "Drzwi odblokowane!\nWyjdź drzwiami po prawej — SPACJA lub E"
	tutorial_toast.visible = true
	toast_panel.modulate.a = 0.0
	_tutorial_tween = create_tween()
	_tutorial_tween.tween_property(toast_panel, "modulate:a", 1.0, 0.3)


# ---------------------------------------------------------------
# NAV
# ---------------------------------------------------------------

func _restart_scene() -> void:
	var gs := get_node_or_null("/root/GameState")
	if gs != null and gs.has_method("restore_level_start_stats"):
		gs.call("restore_level_start_stats")
	elif gs != null and gs.has_method("restore_level_start_health"):
		gs.call("restore_level_start_health")
	get_tree().paused = false
	get_tree().reload_current_scene()


func _return_to_menu() -> void:
	var gs := get_node_or_null("/root/GameState")
	if gs != null and gs.has_method("reset_run"):
		gs.reset_run()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
