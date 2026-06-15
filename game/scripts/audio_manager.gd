extends Node

## Central audio: creates Music/SFX buses (routed to Master, so the Settings
## master-volume slider scales everything), plays looping background music with
## fade transitions, lets bosses override the music while a fight is on, and
## offers a fire-and-forget play_sfx() for one-shot sound effects.

const MUSIC_BUS := "Music"
const SFX_BUS := "SFX"
const FADE := 0.6

const MUSIC_DIR := "res://assets/audio/music/"
const SFX_DIR := "res://assets/audio/sfx/"

const MUSIC_KEYS := ["menu_theme", "gameplay_theme", "boss_vine", "boss_mushroom", "boss_palm"]
const SFX_KEYS := [
	"ui_click", "shoot_water", "shoot_acid", "melee", "hit_enemy", "enemy_die",
	"player_hurt", "pickup_water", "pickup_beer", "pickup_medkit", "beer_drink", "door_open",
	"level_complete", "game_over", "snake_eat", "snake_over", "water_refill", "boss_defeat",
]

var _music: Dictionary = {}
var _sfx: Dictionary = {}
var _player: AudioStreamPlayer = null
var _base_key: String = ""
var _current_key: String = ""
var _boss_active: bool = false
var _fade: Tween = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Buses exist + their volumes are owned by the Settings autoload; just make
	# sure they're present in case Settings hasn't created them yet.
	_ensure_bus(MUSIC_BUS)
	_ensure_bus(SFX_BUS)

	for k in MUSIC_KEYS:
		var s = load(MUSIC_DIR + k + ".wav")
		if s is AudioStreamWAV:
			# Loop the whole track. get_length()*mix_rate gives the frame count
			# regardless of the imported compression format (PCM / QOA).
			s.loop_mode = AudioStreamWAV.LOOP_FORWARD
			s.loop_begin = 0
			s.loop_end = int(s.get_length() * s.mix_rate)
		_music[k] = s
	for k in SFX_KEYS:
		_sfx[k] = load(SFX_DIR + k + ".wav")

	_player = AudioStreamPlayer.new()
	_player.bus = MUSIC_BUS
	_player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_player)


func _ensure_bus(bus_name: String) -> void:
	if AudioServer.get_bus_index(bus_name) == -1:
		var idx := AudioServer.bus_count
		AudioServer.add_bus(idx)
		AudioServer.set_bus_name(idx, bus_name)
		AudioServer.set_bus_send(idx, "Master")


# ---------------------------------------------------------------
# MUSIC
# ---------------------------------------------------------------

func play_music(key: String) -> void:
	_base_key = key
	if not _boss_active:
		_switch(key)


func play_boss_music(key: String) -> void:
	_boss_active = true
	_switch(key)


func clear_boss_music() -> void:
	if not _boss_active:
		return
	_boss_active = false
	if _base_key != "":
		_switch(_base_key)
	else:
		_fade_out()


func stop_music() -> void:
	_base_key = ""
	_boss_active = false
	_fade_out()


func _switch(key: String) -> void:
	if not _music.has(key) or _music[key] == null:
		return
	if _current_key == key and _player.playing:
		return
	_current_key = key
	var s = _music[key]
	if _fade and _fade.is_valid():
		_fade.kill()
	_fade = create_tween()
	if _player.playing:
		_fade.tween_property(_player, "volume_db", -40.0, FADE * 0.5)
	_fade.tween_callback(func() -> void:
		_player.stream = s
		_player.volume_db = -40.0
		_player.play())
	_fade.tween_property(_player, "volume_db", 0.0, FADE * 0.5)


func _fade_out() -> void:
	_current_key = ""
	if not _player.playing:
		return
	if _fade and _fade.is_valid():
		_fade.kill()
	_fade = create_tween()
	_fade.tween_property(_player, "volume_db", -40.0, FADE * 0.5)
	_fade.tween_callback(_player.stop)


# ---------------------------------------------------------------
# SFX
# ---------------------------------------------------------------

func play_sfx(key: String, volume_db: float = 0.0) -> void:
	if not _sfx.has(key) or _sfx[key] == null:
		return
	var p := AudioStreamPlayer.new()
	p.bus = SFX_BUS
	p.stream = _sfx[key]
	p.volume_db = volume_db
	p.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(p)
	p.finished.connect(p.queue_free)
	p.play()
