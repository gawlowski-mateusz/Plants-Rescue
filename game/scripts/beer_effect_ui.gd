extends Control


@onready var blur: ColorRect = $Blur
@onready var inventory_panel: PanelContainer = $InventoryPanel
@onready var icon: TextureRect = $InventoryPanel/MarginContainer/HBox/Icon
@onready var count_label: Label = $InventoryPanel/MarginContainer/HBox/Count
@onready var timer_label: Label = $InventoryPanel/MarginContainer/HBox/Timer

var _beer_count: int = 0
var _beer_effect_active: bool = false


func _ready() -> void:
	if icon != null:
		icon.texture = BeerVisuals.get_beer_texture()
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	set_beer_count(0)
	set_beer_time_left(0.0)
	set_beer_effect_active(false)


func set_beer_count(count: int) -> void:
	var clamped := maxi(count, 0)
	_beer_count = clamped
	if count_label != null:
		count_label.text = str(clamped)
		count_label.visible = clamped > 0
	if inventory_panel != null:
		inventory_panel.visible = clamped > 0 or _beer_effect_active


func set_beer_effect_active(active: bool) -> void:
	_beer_effect_active = active
	if blur != null:
		blur.visible = active
	if timer_label != null:
		timer_label.visible = active
	if inventory_panel != null:
		inventory_panel.visible = _beer_count > 0 or active


func set_beer_time_left(time_left: float) -> void:
	if timer_label == null:
		return

	var t := maxf(time_left, 0.0)
	if t <= 0.0:
		timer_label.text = ""
		return

	# Show integer seconds remaining.
	var secs := int(ceil(t))
	timer_label.text = "%ds" % secs


func _on_player_beer_count_changed(count: int) -> void:
	set_beer_count(count)


func _on_player_beer_effect_active_changed(active: bool) -> void:
	set_beer_effect_active(active)


func _on_player_beer_effect_time_left_changed(time_left: float) -> void:
	set_beer_time_left(time_left)
