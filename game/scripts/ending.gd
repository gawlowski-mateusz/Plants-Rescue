extends Control

## Campaign ending screen. Picks one of three variants based on how many
## friendly plants the player killed during the full run (tracked in GameState):
##   1 = peaceful (killed none), 2 = neutral (a few), 3 = chaos (>=6).

@onready var bg: TextureRect = %BG
@onready var title: Label = %Title
@onready var summary: Label = %Summary
@onready var stats: Label = %Stats
@onready var back_btn: Button = %BackBtn
@onready var bottom_panel: PanelContainer = $BottomPanel
@onready var bottom_vbox: VBoxContainer = $BottomPanel/VBox


func _ready() -> void:
	var variant: int = GameState.get_ending_variant()
	var d: Dictionary = _variant_data(variant)

	bg.texture = load(d["art"])
	title.text = d["title"]
	title.add_theme_color_override("font_color", d["color"])
	summary.text = d["summary"]
	stats.text = "Uratowane rośliny: %d        Zniszczone rośliny: %d" % [
		GameState.campaign_plants_watered, GameState.campaign_plants_killed]
	# Grow the bottom panel upward so longer endings are never clipped.
	call_deferred("_fit_bottom_panel")

	back_btn.pressed.connect(_back_to_menu)
	# The finishing level already plays a completion chime; here we just set the
	# mood music for the ending (calm for peaceful/neutral, tense for chaos).
	AudioManager.play_music(d["music"])


func _variant_data(variant: int) -> Dictionary:
	match variant:
		1:
			return {
				"art": "res://assets/images/endings/ending_peaceful.png",
				"title": "OGRÓD OCALONY",
				"color": Color(0.55, 1.0, 0.45),
				"music": "menu_theme",
				"sfx": "level_complete",
				"summary": "Udało się! Wszystkie przyjazne rośliny zostały podlane, "
					+ "a po zbuntowanych zostały już tylko liście. Jednakże zrobiła się "
					+ "niemała pustka, ale trzeba patrzeć na pozytywy — mieszkanie "
					+ "ocalało, a koledzy po powrocie z wyspy nigdy się nie domyślą, "
					+ "do czego tu doszło!",
			}
		3:
			return {
				"art": "res://assets/images/endings/ending_chaos.png",
				"title": "ROŚLINNA APOKALIPSA",
				"color": Color(1.0, 0.35, 0.25),
				"music": "boss_palm",
				"sfx": "game_over",
				"summary": "Ja tutaj stawiam warunki — rzeźnia, która tu powstała, "
					+ "była wyłącznie na ich życzenie. To rośliny powinny mi być "
					+ "podległe, a mord będzie dla nich nauczką na przyszłość... "
					+ "Mieszkanie jest w opłakanym stanie, podobnie jak moje "
					+ "samopoczucie. Nawet nie chcę myśleć, co pomyślą moi koledzy, "
					+ "kiedy wrócą z wyspy i zobaczą, do czego tu doszło. Jestem "
					+ "skończony — tak jak wszystkie rośliny, które zabiłem...",
			}
		_:
			return {
				"art": "res://assets/images/endings/ending_neutral.png",
				"title": "KRUCHY POKÓJ",
				"color": Color(0.95, 0.88, 0.55),
				"music": "menu_theme",
				"sfx": "level_complete",
				"summary": "Próbowałem uratować wszystkie, lecz jak widać każdy z nas "
					+ "popełnia mniejsze lub większe błędy. Większość moich roślin "
					+ "przeżyła, a te, które poległy, musiałem szybko zakopywać w "
					+ "śmietniku... Mimo wszystko trzeba patrzeć na pozytywy — "
					+ "mieszkanie ocalało, a koledzy po powrocie z wyspy nigdy się "
					+ "nie domyślą, do czego tu doszło!",
			}


func _fit_bottom_panel() -> void:
	# Panel keeps its bottom edge (offset_bottom) and extends its top edge up to
	# fit the content plus the stylebox margins (22 px top + 22 px bottom).
	var needed: float = bottom_vbox.get_combined_minimum_size().y + 44.0
	bottom_panel.offset_top = bottom_panel.offset_bottom - needed


func _back_to_menu() -> void:
	AudioManager.play_sfx("ui_click")
	GameState.reset_run()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel") \
			or event.is_action_pressed("interact"):
		_back_to_menu()
		get_viewport().set_input_as_handled()
