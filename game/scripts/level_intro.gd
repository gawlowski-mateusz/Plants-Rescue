extends CanvasLayer

## Brief title-card popup shown at the start of each level: the level number,
## its name and a short narrative line. Fades in, holds, fades out, then frees
## itself. Non-blocking; the player can dismiss it early with E / Spacja / Esc.

@onready var root: Control = $Root
@onready var number_label: Label = %NumberLabel
@onready var name_label: Label = %NameLabel
@onready var description_label: Label = %DescriptionLabel

var _tween: Tween = null
var _can_skip: bool = false


func _ready() -> void:
	visible = false


func show_intro(number: int, level_name: String, description: String = "") -> void:
	number_label.text = "POZIOM %d" % number
	name_label.text = level_name
	if description_label != null:
		description_label.text = description
		description_label.visible = not description.strip_edges().is_empty()

	# Longer narrative gets more reading time; a bare title card stays brief.
	var hold: float = 1.8
	if not description.strip_edges().is_empty():
		hold = clampf(float(description.length()) * 0.04, 5.0, 10.0)

	root.modulate = Color(1, 1, 1, 0.0)
	visible = true

	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(root, "modulate:a", 1.0, 0.35)
	_tween.tween_callback(func() -> void: _can_skip = true)
	_tween.tween_interval(hold)
	_tween.tween_callback(func() -> void: _can_skip = false)
	_tween.tween_property(root, "modulate:a", 0.0, 0.5)
	_tween.tween_callback(queue_free)


func _unhandled_input(event: InputEvent) -> void:
	if not _can_skip:
		return
	if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept") \
			or event.is_action_pressed("ui_cancel"):
		_skip()


func _skip() -> void:
	_can_skip = false
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(root, "modulate:a", 0.0, 0.3)
	_tween.tween_callback(queue_free)
