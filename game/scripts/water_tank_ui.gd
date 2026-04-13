extends Control


@onready var value_label: Label = $Panel/MarginContainer/VBoxContainer/Value
@onready var water_bar: ProgressBar = $Panel/MarginContainer/VBoxContainer/BarFrame/WaterBar

var pending_current: int = 100
var pending_max_capacity: int = 100
var has_pending_update: bool = false


func _ready() -> void:
	_configure_bar(water_bar)

	if has_pending_update:
		_apply_water_amount(pending_current, pending_max_capacity)
		has_pending_update = false
	else:
		_apply_water_amount(100, 100)


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


func _on_player_water_capacity_changed(current: int, max_capacity: int) -> void:
	set_water_amount(current, max_capacity)