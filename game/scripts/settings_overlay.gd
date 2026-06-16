extends CanvasLayer

## Reusable settings panel (music volume + SFX volume + brightness). Used both
## from the main menu (open(false) -> just a panel) and as an in-game pause menu
## (open(true) -> pauses the tree and shows a "back to menu" button). The sliders
## are bound to the Settings autoload, which persists and applies them globally.

signal closed

@onready var music_slider: HSlider = %MusicSlider
@onready var music_value: Label = %MusicValue
@onready var sfx_slider: HSlider = %SfxSlider
@onready var sfx_value: Label = %SfxValue
@onready var brightness_slider: HSlider = %BrightnessSlider
@onready var brightness_value: Label = %BrightnessValue
@onready var resume_btn: Button = %ResumeBtn
@onready var controls_btn: Button = %ControlsBtn
@onready var menu_btn: Button = %MenuBtn

const CONTROLS_SCENE: PackedScene = preload("res://scenes/controls_overlay.tscn")
const CONFIRM_SCENE: PackedScene = preload("res://scenes/confirm_dialog.tscn")

var _in_game: bool = false
var _syncing: bool = false
var _controls: CanvasLayer = null
var _confirm: CanvasLayer = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	resume_btn.pressed.connect(_close)
	controls_btn.pressed.connect(_open_controls)
	menu_btn.pressed.connect(_on_menu_pressed)
	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	brightness_slider.value_changed.connect(_on_brightness_changed)

	_controls = CONTROLS_SCENE.instantiate()
	add_child(_controls)
	_confirm = CONFIRM_SCENE.instantiate()
	add_child(_confirm)


func _open_controls() -> void:
	if _controls != null and _controls.has_method("open"):
		_controls.call("open")


func open(in_game: bool) -> void:
	_in_game = in_game
	_sync_from_settings()
	menu_btn.visible = in_game
	resume_btn.text = "Wznów" if in_game else "Zamknij"
	visible = true
	if in_game:
		get_tree().paused = true


func is_open() -> bool:
	return visible


func _close() -> void:
	visible = false
	if _in_game:
		get_tree().paused = false
		_in_game = false
	closed.emit()


func _on_menu_pressed() -> void:
	# Confirm before abandoning the run (error prevention, Nielsen H3/H5).
	_confirm.call("ask",
		"Wrócić do menu głównego?\nPostęp bieżącej rozgrywki przepadnie.",
		Callable(self, "_do_return_to_menu"))


func _do_return_to_menu() -> void:
	get_tree().paused = false
	var gs := get_node_or_null("/root/GameState")
	if gs != null and gs.has_method("reset_run"):
		gs.call("reset_run")
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


# ---------------------------------------------------------------
# SLIDERS
# ---------------------------------------------------------------

func _sync_from_settings() -> void:
	var s := get_node_or_null("/root/Settings")
	_syncing = true
	if s != null:
		music_slider.value = s.music_volume
		sfx_slider.value = s.sfx_volume
		brightness_slider.value = s.brightness
	_syncing = false
	_update_value_labels()


func _on_music_changed(value: float) -> void:
	if _syncing:
		return
	var s := get_node_or_null("/root/Settings")
	if s != null and s.has_method("set_music_volume"):
		s.call("set_music_volume", value)
	_update_value_labels()


func _on_sfx_changed(value: float) -> void:
	if _syncing:
		return
	var s := get_node_or_null("/root/Settings")
	if s != null and s.has_method("set_sfx_volume"):
		s.call("set_sfx_volume", value)
	_update_value_labels()


func _on_brightness_changed(value: float) -> void:
	if _syncing:
		return
	var s := get_node_or_null("/root/Settings")
	if s != null and s.has_method("set_brightness"):
		s.call("set_brightness", value)
	_update_value_labels()


func _update_value_labels() -> void:
	music_value.text = "%d%%" % int(round(music_slider.value * 100.0))
	sfx_value.text = "%d%%" % int(round(sfx_slider.value * 100.0))
	brightness_value.text = "%d%%" % int(round(brightness_slider.value * 100.0))


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	# Let the controls/confirm sub-overlays consume Esc while they are open.
	if _controls != null and _controls.has_method("is_open") and bool(_controls.call("is_open")):
		return
	if _confirm != null and _confirm.has_method("is_open") and bool(_confirm.call("is_open")):
		return
	if event.is_action_pressed("ui_cancel"):
		_close()
		get_viewport().set_input_as_handled()
