extends Node2D
class_name InteractionPrompt

## Small contextual prompt that floats above an interactive object and appears
## only while the player stands next to it (Nielsen H6 — recognition over recall,
## replacing one-shot tutorial text). Add as a child of the object's Area2D and
## toggle with show_prompt()/hide_prompt() from body_entered/body_exited.

const PIXEL_THEME: Theme = preload("res://assets/themes/pixel_theme.tres")

var _label: Label = null
var _tween: Tween = null


func _ready() -> void:
	z_index = 80
	visible = false
	_label = Label.new()
	_label.theme = PIXEL_THEME
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.add_theme_font_size_override("font_size", 16)
	_label.add_theme_color_override("font_color", Color(1, 1, 0.8, 1))

	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.1, 0.07, 0.05, 0.92)
	sb.border_width_left = 2
	sb.border_width_top = 2
	sb.border_width_right = 2
	sb.border_width_bottom = 2
	sb.border_color = Color(0.85, 0.7, 0.3, 1)
	sb.content_margin_left = 10.0
	sb.content_margin_top = 5.0
	sb.content_margin_right = 10.0
	sb.content_margin_bottom = 5.0
	sb.anti_aliasing = false
	_label.add_theme_stylebox_override("normal", sb)

	add_child(_label)


func set_text(text: String) -> void:
	if _label == null:
		return
	_label.text = text
	# Center the box above the object based on its actual content size
	# (Label computes its minimum size synchronously once font + text are set).
	var box: Vector2 = _label.get_minimum_size()
	_label.position = Vector2(-box.x * 0.5, -box.y - 64.0)


func show_prompt() -> void:
	if visible:
		return
	visible = true
	modulate.a = 0.0
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 1.0, 0.15)


func hide_prompt() -> void:
	visible = false
	if _tween != null and _tween.is_valid():
		_tween.kill()
