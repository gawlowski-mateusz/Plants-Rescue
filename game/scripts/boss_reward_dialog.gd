extends CanvasLayer


signal closed


@onready var title_label: Label = $Panel/VBox/Title
@onready var body_label: Label = $Panel/VBox/Body
@onready var ok_button: Button = $Panel/VBox/OkBtn


func _ready() -> void:
	visible = false
	ok_button.pressed.connect(_close)


func show_reward(title: String, body: String) -> void:
	title_label.text = title
	body_label.text = body
	visible = true
	ok_button.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return

	if event is InputEventKey and event.echo:
		return

	if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		_close()
		get_viewport().set_input_as_handled()


func _close() -> void:
	if not visible:
		return
	visible = false
	closed.emit()
