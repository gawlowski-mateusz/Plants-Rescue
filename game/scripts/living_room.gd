extends Node2D


enum State { PLAY, COMPLETE, GAME_OVER }


const TOTAL_PLANTS: int = 3
const TOTAL_ENEMIES: int = 4


@onready var player: CharacterBody2D = $Player
@onready var door2: Door = $Doors/Door2
@onready var finish_trigger: Area2D = $FinishTrigger

@onready var plants_label: Label = $UI/Objectives/VBox/PlantsLabel
@onready var enemies_label: Label = $UI/Objectives/VBox/EnemiesLabel

@onready var tutorial_toast: CanvasLayer = $Overlays/TutorialToast
@onready var toast_label: Label = $Overlays/TutorialToast/Panel/Label
@onready var toast_panel: Control = $Overlays/TutorialToast/Panel

@onready var completion_screen: CanvasLayer = $Overlays/CompletionScreen
@onready var completion_time_label: Label = $Overlays/CompletionScreen/Panel/VBox/TimeLabel
@onready var completion_menu_btn: Button = $Overlays/CompletionScreen/Panel/VBox/MenuBtn

@onready var game_over_screen: CanvasLayer = $Overlays/GameOverScreen
@onready var game_over_restart_btn: Button = $Overlays/GameOverScreen/Panel/VBox/RestartBtn
@onready var game_over_menu_btn: Button = $Overlays/GameOverScreen/Panel/VBox/MenuBtn


var state: int = State.PLAY
var plants_watered: int = 0
var enemies_killed: int = 0
var elapsed: float = 0.0

var _tutorial_tween: Tween = null
var _tutorial_queue: Array = []
var _tutorial_playing: bool = false


func _ready() -> void:
	tutorial_toast.visible = false
	completion_screen.visible = false
	game_over_screen.visible = false

	# Connect plants
	for plant in $Plants.get_children():
		if plant.has_signal("plant_fully_watered"):
			plant.plant_fully_watered.connect(_on_plant_watered)

	# Connect enemies
	for enemy in $Enemies.get_children():
		if enemy.has_signal("died"):
			enemy.died.connect(_on_enemy_died)

	door2.interacted.connect(_on_door2_interacted)
	door2.opened.connect(_on_door2_opened)
	finish_trigger.body_entered.connect(_on_finish_trigger)

	player.health_changed.connect(_on_player_health_changed)

	completion_menu_btn.pressed.connect(_return_to_menu)
	game_over_restart_btn.pressed.connect(_restart_scene)
	game_over_menu_btn.pressed.connect(_return_to_menu)

	_update_labels()

	# Quick onboarding sequence
	_queue_tutorial("LPM — strzelaj wodą\nPodlej rośliny aby je uratować", 4.5)
	_queue_tutorial("X — przełącz między wodą a kwasem\nKwas rani wrogów", 4.5)
	_queue_tutorial("Prawy przycisk myszy — auto-celowanie\nw wroga pod kursorem", 4.5)
	_queue_tutorial("Uratuj wszystkie 3 rośliny\ni pokonaj 4 zmutowane potwory", 4.5)


func _process(delta: float) -> void:
	if state == State.PLAY:
		elapsed += delta


# ---------------------------------------------------------------
# OBJECTIVES
# ---------------------------------------------------------------

func _on_plant_watered() -> void:
	plants_watered += 1
	_update_labels()
	_check_objectives()


func _on_enemy_died() -> void:
	enemies_killed += 1
	_update_labels()
	_check_objectives()


func _update_labels() -> void:
	plants_label.text = "Rośliny podlane: %d / %d" % [plants_watered, TOTAL_PLANTS]
	enemies_label.text = "Wrogowie pokonani: %d / %d" % [enemies_killed, TOTAL_ENEMIES]


func _check_objectives() -> void:
	if state != State.PLAY:
		return
	if plants_watered >= TOTAL_PLANTS and enemies_killed >= TOTAL_ENEMIES:
		door2.unlock()
		_queue_tutorial("Wszystko uratowane!\nDrzwi po prawej są otwarte — ucieknij stąd", 5.0)


# ---------------------------------------------------------------
# DOOR / COMPLETION
# ---------------------------------------------------------------

func _on_door2_interacted(door_id: String) -> void:
	if door_id != "door2":
		return
	if state != State.PLAY:
		return
	player.input_locked = true
	door2.open()


func _on_door2_opened(_door_id: String) -> void:
	await get_tree().create_timer(0.35).timeout
	# After the door opens the player may just walk into FinishTrigger,
	# but we also force-complete here in case of edge cases.
	_complete()


func _on_finish_trigger(body: Node2D) -> void:
	if body != player:
		return
	_complete()


func _complete() -> void:
	if state != State.PLAY:
		return
	state = State.COMPLETE
	player.input_locked = true
	var mins := int(elapsed) / 60
	var secs := int(elapsed) % 60
	completion_time_label.text = "Czas: %02d:%02d" % [mins, secs]
	completion_screen.visible = true


# ---------------------------------------------------------------
# HEALTH / GAME OVER
# ---------------------------------------------------------------

func _on_player_health_changed(current: int, _max_health: int) -> void:
	if current <= 0 and state == State.PLAY:
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
