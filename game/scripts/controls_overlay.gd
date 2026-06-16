extends CanvasLayer

## On-demand controls reference. Reachable from the settings/pause overlay, so
## the player can always look up the controls (Nielsen H6/H10). Shown on top of
## the settings overlay; closed with the button or ui_cancel.

signal closed

const ENTRIES := [
	["WASD", "Ruch"],
	["Lewy przycisk myszy", "Atak nożyczkami (wręcz)"],
	["Prawy przycisk myszy", "Strzał — woda / kwas"],
	["X", "Przełącz wodę / kwas"],
	["Środkowy przycisk myszy", "Auto-celowanie wroga"],
	["Q", "Wypij piwo (przyspieszenie)"],
	["SPACJA / E", "Interakcja (drzwi, lodówka, apteczka)"],
	["ESC", "Pauza / menu ustawień"],
	["F11", "Pełny ekran"],
]

@onready var list: VBoxContainer = %List
@onready var close_btn: Button = %CloseBtn


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	close_btn.pressed.connect(close)
	_build_rows()


func _build_rows() -> void:
	for entry in ENTRIES:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 18)

		var key := Label.new()
		key.text = entry[0]
		key.custom_minimum_size = Vector2(280, 0)
		key.add_theme_color_override("font_color", Color(0.95, 0.82, 0.4, 1))
		key.add_theme_font_size_override("font_size", 22)

		var action := Label.new()
		action.text = entry[1]
		action.add_theme_color_override("font_color", Color(0.95, 0.95, 0.85, 1))
		action.add_theme_font_size_override("font_size", 22)

		row.add_child(key)
		row.add_child(action)
		list.add_child(row)


func open() -> void:
	visible = true


func is_open() -> bool:
	return visible


func close() -> void:
	if not visible:
		return
	visible = false
	closed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()
