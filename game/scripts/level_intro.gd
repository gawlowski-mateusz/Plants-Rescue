extends CanvasLayer

## Brief title-card popup shown at the start of each level: the level number
## and its name. Fades in, holds, fades out, then frees itself. Non-blocking.

@onready var root: Control = $Root
@onready var number_label: Label = %NumberLabel
@onready var name_label: Label = %NameLabel


func _ready() -> void:
	visible = false


func show_intro(number: int, level_name: String) -> void:
	number_label.text = "POZIOM %d" % number
	name_label.text = level_name
	root.modulate = Color(1, 1, 1, 0.0)
	visible = true
	var t := create_tween()
	t.tween_property(root, "modulate:a", 1.0, 0.35)
	t.tween_interval(1.8)
	t.tween_property(root, "modulate:a", 0.0, 0.5)
	t.tween_callback(queue_free)
