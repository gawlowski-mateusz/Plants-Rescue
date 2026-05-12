extends Node


const HEALTH_PER_HEART: int = 30
const BASE_HEARTS: int = 3
const BASE_MAX_HEALTH: int = BASE_HEARTS * HEALTH_PER_HEART

# How much the Vine boss increases the scissors hitbox range.
const SCISSORS_RANGE_BONUS_MULTIPLIER: float = 1.35


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

var boss_vine_defeated: bool = false
var boss_mushroom_defeated: bool = false
var boss_palm_defeated: bool = false


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
	boss_vine_defeated = false
	boss_mushroom_defeated = false
	boss_palm_defeated = false


func enter_single_level_mode() -> void:
	is_single_level_mode = true


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
