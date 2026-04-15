extends Control


const MODE_WATER := 0
const MODE_ACID := 1

const WATER_COLOR := Color(0.30, 0.62, 0.95, 1.0)
const ACID_COLOR := Color(0.45, 0.85, 0.30, 1.0)
const INACTIVE_COLOR := Color(0.55, 0.45, 0.30, 1.0)

@onready var water_title: Label = $Panel/MarginContainer/VBoxContainer/WaterHeader/Title
@onready var water_mode_tag: Label = $Panel/MarginContainer/VBoxContainer/WaterHeader/ModeTag
@onready var water_bar: ProgressBar = $Panel/MarginContainer/VBoxContainer/BarFrame/WaterBar
@onready var water_value: Label = $Panel/MarginContainer/VBoxContainer/BarFrame/Value
@onready var acid_title: Label = $Panel/MarginContainer/VBoxContainer/AcidHeader/AcidTitle
@onready var acid_timer_label: Label = $Panel/MarginContainer/VBoxContainer/AcidHeader/AcidCooldown
@onready var acid_bar: ProgressBar = $Panel/MarginContainer/VBoxContainer/AcidBarFrame/AcidBar

var pending_current: int = 100
var pending_max_capacity: int = 100
var has_pending_update: bool = false
var pending_shot_mode: int = MODE_WATER
var has_pending_mode_update: bool = false
var pending_acid_current: int = 100
var pending_acid_max_capacity: int = 100
var pending_acid_is_cooling_down: bool = false
var pending_acid_cooldown_left: float = 0.0
var has_pending_acid_update: bool = false


func _ready() -> void:
	_configure_bar(water_bar)
	_configure_bar(acid_bar)

	if has_pending_update:
		_apply_water_amount(pending_current, pending_max_capacity)
		has_pending_update = false
	else:
		_apply_water_amount(100, 100)

	if has_pending_mode_update:
		_apply_shot_mode(pending_shot_mode)
		has_pending_mode_update = false
	else:
		_apply_shot_mode(MODE_WATER)

	if has_pending_acid_update:
		_apply_acid_status(
			pending_acid_current,
			pending_acid_max_capacity,
			pending_acid_is_cooling_down,
			pending_acid_cooldown_left
		)
		has_pending_acid_update = false
	else:
		_apply_acid_status(100, 100, false, 0.0)


func _configure_bar(bar: ProgressBar) -> void:
	bar.min_value = 0.0
	bar.step = 1.0
	bar.show_percentage = false


func set_water_amount(current: int, max_capacity: int) -> void:
	if not is_node_ready() or water_bar == null or water_value == null:
		pending_current = current
		pending_max_capacity = max_capacity
		has_pending_update = true
		return

	_apply_water_amount(current, max_capacity)


func _apply_water_amount(current: int, max_capacity: int) -> void:
	if max_capacity <= 0:
		return

	var clamped_current := clampi(current, 0, max_capacity)

	water_bar.max_value = float(max_capacity)
	water_bar.value = float(clamped_current)

	water_value.text = "%d / %d" % [clamped_current, max_capacity]


func set_shot_mode(mode: int) -> void:
	if not is_node_ready() or water_mode_tag == null:
		pending_shot_mode = mode
		has_pending_mode_update = true
		return

	_apply_shot_mode(mode)


func _apply_shot_mode(mode: int) -> void:
	if mode == MODE_ACID:
		water_mode_tag.text = ""
		water_title.modulate = INACTIVE_COLOR
		acid_title.modulate = Color.WHITE
		acid_timer_label.text = acid_timer_label.text if acid_timer_label.text != "" else "Gotowy"
		_set_acid_mode_active(true)
		return

	water_mode_tag.text = "[AKTYWNA]"
	water_title.modulate = Color.WHITE
	acid_title.modulate = INACTIVE_COLOR
	_set_acid_mode_active(false)


func _set_acid_mode_active(active: bool) -> void:
	# Show a tag on acid title when acid is the active mode
	if not active:
		return


func set_acid_status(current: int, max_capacity: int, is_cooling_down: bool, cooldown_left: float) -> void:
	if not is_node_ready() or acid_bar == null or acid_timer_label == null:
		pending_acid_current = current
		pending_acid_max_capacity = max_capacity
		pending_acid_is_cooling_down = is_cooling_down
		pending_acid_cooldown_left = cooldown_left
		has_pending_acid_update = true
		return

	_apply_acid_status(current, max_capacity, is_cooling_down, cooldown_left)


func _apply_acid_status(current: int, max_capacity: int, is_cooling_down: bool, cooldown_left: float) -> void:
	if max_capacity <= 0:
		return

	var clamped_current := clampi(current, 0, max_capacity)

	acid_bar.max_value = float(max_capacity)
	acid_bar.value = float(clamped_current)

	if is_cooling_down:
		acid_timer_label.text = "%.1fs" % maxf(cooldown_left, 0.0)
		acid_timer_label.modulate = Color(1.0, 0.85, 0.55, 1.0)
	else:
		acid_timer_label.text = "Gotowy"
		acid_timer_label.modulate = ACID_COLOR


func _on_player_water_capacity_changed(current: int, max_capacity: int) -> void:
	set_water_amount(current, max_capacity)


func _on_player_shot_mode_changed(mode: int) -> void:
	set_shot_mode(mode)


func _on_player_acid_status_changed(current: int, max_capacity: int, is_cooling_down: bool, cooldown_left: float) -> void:
	set_acid_status(current, max_capacity, is_cooling_down, cooldown_left)
