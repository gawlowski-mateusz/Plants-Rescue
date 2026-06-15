extends Node

## Global settings autoload: persists music + SFX volume and screen brightness
## and applies them across every scene. Music/SFX volumes drive the Music and
## SFX audio buses; brightness is a full-screen overlay on its own CanvasLayer.

const SAVE_PATH: String = "user://settings.cfg"

const MIN_BRIGHTNESS: float = 0.3
const MAX_BRIGHTNESS: float = 1.6

const MUSIC_BUS := "Music"
const SFX_BUS := "SFX"

var music_volume: float = 0.6
var sfx_volume: float = 0.9
var brightness: float = 1.0

var _overlay_layer: CanvasLayer = null
var _overlay_rect: ColorRect = null
var _overlay_material: CanvasItemMaterial = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_overlay()
	_ensure_bus(MUSIC_BUS)
	_ensure_bus(SFX_BUS)
	_load()
	_apply_music()
	_apply_sfx()
	_apply_brightness()


func _input(event: InputEvent) -> void:
	# Global fullscreen toggle (F11). Works in every scene since this is an autoload.
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F11:
		_toggle_fullscreen()
		get_viewport().set_input_as_handled()


func _toggle_fullscreen() -> void:
	var mode := DisplayServer.window_get_mode()
	if mode == DisplayServer.WINDOW_MODE_FULLSCREEN or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


func _build_overlay() -> void:
	_overlay_layer = CanvasLayer.new()
	_overlay_layer.layer = 128
	_overlay_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_overlay_layer)

	_overlay_material = CanvasItemMaterial.new()
	_overlay_material.blend_mode = CanvasItemMaterial.BLEND_MODE_MIX

	_overlay_rect = ColorRect.new()
	_overlay_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay_rect.color = Color(0, 0, 0, 0)
	_overlay_rect.material = _overlay_material
	_overlay_layer.add_child(_overlay_rect)


# ---------------------------------------------------------------
# PUBLIC API (used by the settings overlay sliders)
# ---------------------------------------------------------------

func set_music_volume(value: float) -> void:
	music_volume = clampf(value, 0.0, 1.0)
	_apply_music()
	_save()


func set_sfx_volume(value: float) -> void:
	sfx_volume = clampf(value, 0.0, 1.0)
	_apply_sfx()
	_save()


func set_brightness(value: float) -> void:
	brightness = clampf(value, MIN_BRIGHTNESS, MAX_BRIGHTNESS)
	_apply_brightness()
	_save()


# ---------------------------------------------------------------
# APPLY
# ---------------------------------------------------------------

func _ensure_bus(bus_name: String) -> void:
	if AudioServer.get_bus_index(bus_name) == -1:
		var idx := AudioServer.bus_count
		AudioServer.add_bus(idx)
		AudioServer.set_bus_name(idx, bus_name)
		AudioServer.set_bus_send(idx, "Master")


func _apply_bus(bus_name: String, v: float) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx == -1:
		return
	var muted := v <= 0.001
	AudioServer.set_bus_mute(idx, muted)
	AudioServer.set_bus_volume_db(idx, -80.0 if muted else linear_to_db(v))


func _apply_music() -> void:
	_apply_bus(MUSIC_BUS, music_volume)


func _apply_sfx() -> void:
	_apply_bus(SFX_BUS, sfx_volume)


func _apply_brightness() -> void:
	if _overlay_rect == null:
		return
	if brightness >= 1.0:
		# Brighten: add white light on top.
		_overlay_material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		_overlay_rect.color = Color(1, 1, 1, clampf(brightness - 1.0, 0.0, 1.0))
	else:
		# Darken: overlay semi-transparent black.
		_overlay_material.blend_mode = CanvasItemMaterial.BLEND_MODE_MIX
		_overlay_rect.color = Color(0, 0, 0, clampf(1.0 - brightness, 0.0, 1.0))


# ---------------------------------------------------------------
# PERSISTENCE
# ---------------------------------------------------------------

func _save() -> void:
	var config := ConfigFile.new()
	config.set_value("settings", "music_volume", music_volume)
	config.set_value("settings", "sfx_volume", sfx_volume)
	config.set_value("settings", "brightness", brightness)
	config.save(SAVE_PATH)


func _load() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return
	music_volume = clampf(float(config.get_value("settings", "music_volume", 0.6)), 0.0, 1.0)
	sfx_volume = clampf(float(config.get_value("settings", "sfx_volume", 0.9)), 0.0, 1.0)
	brightness = clampf(float(config.get_value("settings", "brightness", 1.0)), MIN_BRIGHTNESS, MAX_BRIGHTNESS)
