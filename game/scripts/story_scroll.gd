extends CanvasLayer

## Reusable parchment "story scroll" shown at the start of a level. Mirrors the
## intro letter: a scroll graphic with a title, narrative body and a Kontynuuj
## button. Pauses the game until dismissed and shrinks the parchment to fit the
## amount of text, so short notes don't float on a huge sheet.

signal continued

# Parchment geometry mirrors the intro letter (920x720 with 170px side margins
# and 160/150 top/bottom margins). Width stays fixed (keeps the side rolls
# looking right); only the height adapts to the text.
const PANEL_WIDTH: float = 920.0
const SIDE_INSET: float = 170.0
const INNER_WIDTH: float = PANEL_WIDTH - SIDE_INSET * 2.0   # 580
const TOP_FRAC: float = 160.0 / 720.0
const BOTTOM_FRAC: float = 150.0 / 720.0
const INNER_H_FRAC: float = 1.0 - TOP_FRAC - BOTTOM_FRAC    # 0.569
const MIN_HEIGHT: float = 440.0
const MAX_HEIGHT: float = 760.0

@onready var panel: Control = $Panel
@onready var vbox: VBoxContainer = $Panel/VBox
@onready var title_label: Label = $Panel/VBox/Title
@onready var body_label: Label = $Panel/VBox/Body
@onready var continue_btn: Button = $Panel/VBox/ContinueBtn


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	continue_btn.pressed.connect(_on_continue)


func show_story(title: String, body: String, pause: bool = true) -> void:
	title_label.text = title
	body_label.text = body
	body_label.custom_minimum_size = Vector2(INNER_WIDTH, 0)
	visible = true
	if pause:
		get_tree().paused = true
	# Sizes resolve only after the labels have laid out the new text.
	call_deferred("_resize_to_text")
	continue_btn.call_deferred("grab_focus")


func _resize_to_text() -> void:
	var sep: float = float(vbox.get_theme_constant("separation"))
	var content: float = title_label.get_minimum_size().y \
			+ body_label.get_minimum_size().y \
			+ continue_btn.get_minimum_size().y \
			+ sep * 2.0
	var h: float = clampf(content / INNER_H_FRAC, MIN_HEIGHT, MAX_HEIGHT)

	panel.offset_left = -PANEL_WIDTH * 0.5
	panel.offset_right = PANEL_WIDTH * 0.5
	panel.offset_top = -h * 0.5
	panel.offset_bottom = h * 0.5

	vbox.offset_left = SIDE_INSET
	vbox.offset_right = -SIDE_INSET
	vbox.offset_top = h * TOP_FRAC
	vbox.offset_bottom = -h * BOTTOM_FRAC


func _on_continue() -> void:
	get_tree().paused = false
	continued.emit()
	queue_free()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		_on_continue()
		get_viewport().set_input_as_handled()
