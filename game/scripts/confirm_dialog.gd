extends CanvasLayer

## Reusable yes/no confirmation for destructive actions (Nielsen H3/H5):
## quitting the game, abandoning a run to the main menu, etc.

@onready var message_label: Label = %Message
@onready var yes_btn: Button = %YesBtn
@onready var no_btn: Button = %NoBtn

var _on_confirm: Callable = Callable()


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	yes_btn.pressed.connect(_on_yes)
	no_btn.pressed.connect(close)


func ask(message: String, on_confirm: Callable) -> void:
	message_label.text = message
	_on_confirm = on_confirm
	visible = true
	no_btn.grab_focus()


func is_open() -> bool:
	return visible


func close() -> void:
	visible = false


func _on_yes() -> void:
	visible = false
	if _on_confirm.is_valid():
		_on_confirm.call()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()
