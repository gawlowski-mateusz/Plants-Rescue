extends Control


const MODE_WATER := 0
const MODE_ACID := 1

const WATER_ICON_COLOR := Color(0.305882, 0.756863, 1.0, 1.0)
const ACID_ICON_COLOR := Color(0.513725, 0.980392, 0.337255, 1.0)

@onready var value_label: Label = $Panel/MarginContainer/VBoxContainer/StatusRow/Value
@onready var mode_icon: ColorRect = $Panel/MarginContainer/VBoxContainer/StatusRow/ModeIcon
@onready var mode_label: Label = $Panel/MarginContainer/VBoxContainer/StatusRow/ModeLabel
@onready var water_bar: ProgressBar = $Panel/MarginContainer/VBoxContainer/BarFrame/WaterBar
@onready var acid_bar: ProgressBar = $Panel/MarginContainer/VBoxContainer/AcidRow/AcidBarFrame/AcidBar
@onready var acid_timer_label: Label = $Panel/MarginContainer/VBoxContainer/AcidRow/AcidCooldown

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
	if not is_node_ready() or water_bar == null or value_label == null:
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

	value_label.text = "%d / %d" % [clamped_current, max_capacity]


func set_shot_mode(mode: int) -> void:
	if not is_node_ready() or mode_icon == null or mode_label == null:
		pending_shot_mode = mode
		has_pending_mode_update = true
		return

	_apply_shot_mode(mode)


func _apply_shot_mode(mode: int) -> void:
	if mode == MODE_ACID:
		mode_icon.color = ACID_ICON_COLOR
		mode_label.text = "ACID"
		mode_label.modulate = ACID_ICON_COLOR
		return

	mode_icon.color = WATER_ICON_COLOR
	mode_label.text = "WATER"
	mode_label.modulate = WATER_ICON_COLOR


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
		acid_timer_label.modulate = Color(0.878431, 0.972549, 0.815686, 1.0)
	else:
		acid_timer_label.text = "Ready"
		acid_timer_label.modulate = ACID_ICON_COLOR


func _on_player_water_capacity_changed(current: int, max_capacity: int) -> void:
	set_water_amount(current, max_capacity)


func _on_player_shot_mode_changed(mode: int) -> void:
	set_shot_mode(mode)


func _on_player_acid_status_changed(current: int, max_capacity: int, is_cooling_down: bool, cooldown_left: float) -> void:
	set_acid_status(current, max_capacity, is_cooling_down, cooldown_left)
