extends Node


const HEALTH_PER_HEART: int = 30
const BASE_HEARTS: int = 3
const BASE_MAX_HEALTH: int = BASE_HEARTS * HEALTH_PER_HEART

# How much the Vine boss increases the scissors hitbox range.
const SCISSORS_RANGE_BONUS_MULTIPLIER: float = 1.35

# Persistent progress (survives app restarts and "new game").
const PROGRESS_SAVE_PATH: String = "user://progress.cfg"
const BASE_LEVELS: Array = [
	"living_room.tscn",
	"kitchen.tscn",
	"bedroom.tscn",
	"balcony.tscn",
]


var beer_count: int = 0

var max_health: int = BASE_MAX_HEALTH
var current_health: int = BASE_MAX_HEALTH

var level_start_health: int = BASE_MAX_HEALTH
var level_start_max_health: int = BASE_MAX_HEALTH
var level_start_water: int = 100
var level_start_acid: int = 100
var level_start_beer: int = 0

var _has_pending_restart: bool = false

var is_single_level_mode: bool = false
var pending_completion_message: String = ""

# Set when moving from the foyer (level 0) into level 1, so that level resets
# the player's water/acid/health to full and skips the duplicated onboarding.
var pending_full_restore: bool = false

var boss_vine_defeated: bool = false
var boss_mushroom_defeated: bool = false
var boss_palm_defeated: bool = false

# Keys are level scene file names (e.g. "living_room.tscn"); value true == completed.
var completed_levels: Dictionary = {}

# Tracking for the campaign endings — only meaningful during a full "new game"
# run played level-by-level to the end. A plant that was watered but later
# corrupted into an enemy and killed counts ONLY as killed.
var is_campaign_run: bool = false
var campaign_plants_watered: int = 0
var campaign_plants_killed: int = 0


func _ready() -> void:
	_load_progress()


func reset_run() -> void:
	beer_count = 0
	max_health = BASE_MAX_HEALTH
	current_health = BASE_MAX_HEALTH
	level_start_health = BASE_MAX_HEALTH
	level_start_max_health = BASE_MAX_HEALTH
	level_start_water = 100
	level_start_acid = 100
	level_start_beer = 0
	_has_pending_restart = false
	is_single_level_mode = false
	pending_completion_message = ""
	pending_full_restore = false
	boss_vine_defeated = false
	boss_mushroom_defeated = false
	boss_palm_defeated = false
	is_campaign_run = false
	campaign_plants_watered = 0
	campaign_plants_killed = 0


func enter_single_level_mode() -> void:
	is_single_level_mode = true


# ---------------------------------------------------------------
# CAMPAIGN RUN + ENDING STATS
# ---------------------------------------------------------------

func start_campaign_run() -> void:
	is_campaign_run = true
	campaign_plants_watered = 0
	campaign_plants_killed = 0


func campaign_record_watered() -> void:
	if not is_campaign_run:
		return
	campaign_plants_watered += 1


func campaign_record_plant_killed(was_watered: bool) -> void:
	if not is_campaign_run:
		return
	campaign_plants_killed += 1
	# A plant counted as watered that's now killed counts ONLY as killed.
	if was_watered:
		campaign_plants_watered = maxi(campaign_plants_watered - 1, 0)


func get_ending_variant() -> int:
	# 1 = peaceful (no plant killed), 2 = neutral (a few), 3 = chaos (>=6).
	if campaign_plants_killed <= 0:
		return 1
	if campaign_plants_killed >= 6:
		return 3
	return 2


func request_full_restore_on_next_level() -> void:
	pending_full_restore = true


func consume_full_restore() -> bool:
	var should := pending_full_restore
	pending_full_restore = false
	return should


func queue_completion_message(message: String) -> void:
	pending_completion_message = message


func consume_completion_message() -> String:
	var msg := pending_completion_message
	pending_completion_message = ""
	return msg


func restore_full_health() -> void:
	max_health = maxi(max_health, 1)
	current_health = max_health


func save_level_start_health() -> void:
	level_start_health = current_health
	level_start_max_health = max_health
	level_start_beer = beer_count


func restore_level_start_health() -> void:
	max_health = maxi(level_start_max_health, 1)
	current_health = clampi(level_start_health, 0, max_health)
	beer_count = maxi(level_start_beer, 0)


func save_level_start_stats(water: int, acid: int) -> void:
	level_start_health = current_health
	level_start_max_health = max_health
	level_start_beer = beer_count
	level_start_water = clampi(water, 0, 100)
	level_start_acid = clampi(acid, 0, 100)


func restore_level_start_stats() -> void:
	max_health = maxi(level_start_max_health, 1)
	current_health = clampi(level_start_health, 0, max_health)
	beer_count = maxi(level_start_beer, 0)
	_has_pending_restart = true


func consume_restart_state() -> Dictionary:
	if not _has_pending_restart:
		return {}
	_has_pending_restart = false
	return {
		"water": level_start_water,
		"acid": level_start_acid,
	}


func set_beer_count(new_count: int) -> void:
	beer_count = maxi(new_count, 0)


func set_health(new_current: int, new_max: int) -> void:
	max_health = maxi(new_max, 1)
	current_health = clampi(new_current, 0, max_health)


func get_scissors_range_multiplier() -> float:
	return SCISSORS_RANGE_BONUS_MULTIPLIER if boss_vine_defeated else 1.0


func award_boss_vine() -> bool:
	if boss_vine_defeated:
		return false
	boss_vine_defeated = true
	return true


func award_boss_mushroom() -> bool:
	if boss_mushroom_defeated:
		return false
	boss_mushroom_defeated = true
	max_health += HEALTH_PER_HEART
	current_health = mini(current_health + HEALTH_PER_HEART, max_health)
	return true


func award_boss_palm() -> bool:
	if boss_palm_defeated:
		return false
	boss_palm_defeated = true
	return true


# ---------------------------------------------------------------
# PERSISTENT PROGRESS (completed levels)
# ---------------------------------------------------------------

func mark_level_completed(level_key: String) -> void:
	var key := level_key.strip_edges()
	if key.is_empty():
		return
	if completed_levels.get(key, false):
		return
	completed_levels[key] = true
	_save_progress()


func is_level_completed(level_key: String) -> bool:
	return bool(completed_levels.get(level_key.strip_edges(), false))


func are_all_levels_completed() -> bool:
	for level_key in BASE_LEVELS:
		if not bool(completed_levels.get(level_key, false)):
			return false
	return true


func reset_progress() -> void:
	completed_levels.clear()
	_save_progress()


func _save_progress() -> void:
	var config := ConfigFile.new()
	for key in completed_levels.keys():
		config.set_value("progress", String(key), bool(completed_levels[key]))
	config.save(PROGRESS_SAVE_PATH)


func _load_progress() -> void:
	completed_levels.clear()
	var config := ConfigFile.new()
	if config.load(PROGRESS_SAVE_PATH) != OK:
		return
	if not config.has_section("progress"):
		return
	for key in config.get_section_keys("progress"):
		if bool(config.get_value("progress", key, false)):
			completed_levels[key] = true
