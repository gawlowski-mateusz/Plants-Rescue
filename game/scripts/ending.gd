extends Control

## Campaign ending screen. Picks one of three variants based on how many
## friendly plants the player killed during the full run (tracked in GameState):
##   1 = peaceful (killed none), 2 = neutral (a few), 3 = chaos (>=6).

@onready var bg: TextureRect = %BG
@onready var title: Label = %Title
@onready var summary: Label = %Summary
@onready var stats: Label = %Stats
@onready var back_btn: Button = %BackBtn


func _ready() -> void:
	var variant: int = GameState.get_ending_variant()
	var d: Dictionary = _variant_data(variant)

	bg.texture = load(d["art"])
	title.text = d["title"]
	title.add_theme_color_override("font_color", d["color"])
	summary.text = d["summary"]
	stats.text = "Uratowane rośliny: %d        Zniszczone rośliny: %d" % [
		GameState.campaign_plants_watered, GameState.campaign_plants_killed]

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
				"summary": "Uratowałeś wszystkie rośliny i nie skrzywdziłeś żadnej.\n"
					+ "Dom znów tętni życiem, a wdzięczna zieleń otula każdy kąt.\n"
					+ "Jesteś prawdziwym obrońcą roślin — zapanował pokój.",
			}
		3:
			return {
				"art": "res://assets/images/endings/ending_chaos.png",
				"title": "ROŚLINNA APOKALIPSA",
				"color": Color(1.0, 0.35, 0.25),
				"music": "boss_palm",
				"sfx": "game_over",
				"summary": "Wybrałeś przemoc. Ogień strawił dom, a rośliny zwróciły\n"
					+ "się przeciw Tobie. Z popiołów wyrasta zielona furia...\n"
					+ "Wojna człowieka z roślinami dopiero się zaczyna.",
			}
		_:
			return {
				"art": "res://assets/images/endings/ending_neutral.png",
				"title": "KRUCHY POKÓJ",
				"color": Color(0.95, 0.88, 0.55),
				"music": "menu_theme",
				"sfx": "level_complete",
				"summary": "Po drodze zdarzyło się kilka pomyłek, lecz dom udało się\n"
					+ "uratować. Większość roślin jest bezpieczna i świat\n"
					+ "odetchnął z ulgą. Nie było idealnie — ale dobrze.",
			}


func _back_to_menu() -> void:
	AudioManager.play_sfx("ui_click")
	GameState.reset_run()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel") \
			or event.is_action_pressed("interact"):
		_back_to_menu()
		get_viewport().set_input_as_handled()
