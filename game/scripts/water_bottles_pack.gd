extends Area2D


@export var starting_bottles: int = 4
@export var refill_amount: int = 25
@export var refill_cooldown: float = 1.0

var bottles_left: int = 4

var _player_in_range: bool = false
var _player: Node2D = null
var _cooldown_left: float = 0.0
var _bubble: Control = null


@onready var _sprite: Sprite2D = $Blocker/Sprite2D


func _ready() -> void:
	bottles_left = clampi(starting_bottles, 0, 4)

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	_refresh_bottles_visual()
	#call_deferred("_setup_water_bubble")


func _setup_water_bubble() -> void:
	var root := get_tree().current_scene
	if root == null:
		return

	var bubble := PanelContainer.new()
	bubble.name = "WaterBubble_" + str(get_instance_id())
	bubble.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.9, 0.97, 1.0, 0.92)
	sb.border_width_left = 2
	sb.border_width_top = 2
	sb.border_width_right = 2
	sb.border_width_bottom = 2
	sb.border_color = Color(0.4, 0.7, 1.0, 1.0)
	sb.corner_radius_top_left = 6
	sb.corner_radius_top_right = 6
	sb.corner_radius_bottom_left = 6
	sb.corner_radius_bottom_right = 6
	sb.content_margin_left = 8.0
	sb.content_margin_top = 4.0
	sb.content_margin_right = 8.0
	sb.content_margin_bottom = 4.0
	sb.anti_aliasing = false
	bubble.add_theme_stylebox_override("panel", sb)

	var lbl := Label.new()
	lbl.text = "Woda"
	lbl.add_theme_font_size_override("font_size", 13)
	lbl.add_theme_color_override("font_color", Color(0.1, 0.3, 0.7, 1.0))
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bubble.add_child(lbl)

	root.add_child(bubble)

	var world_pos: Vector2 = global_position + Vector2(-28, -110)
	bubble.set_position(world_pos)

	_bubble = bubble


func _exit_tree() -> void:
	if is_instance_valid(_bubble):
		_bubble.queue_free()
	_bubble = null


func _process(delta: float) -> void:
	if _cooldown_left <= 0.0:
		return
	_cooldown_left = maxf(_cooldown_left - delta, 0.0)


func _unhandled_input(event: InputEvent) -> void:
	if not _player_in_range or _player == null:
		return
	if bottles_left <= 0:
		return
	if _cooldown_left > 0.0:
		return

	if event is InputEventKey and event.echo:
		return
	if not event.is_action_pressed("interact"):
		return
	if not is_instance_valid(_player):
		return

	if not _player.has_method("refill_water"):
		return

	var did_refill := bool(_player.call("refill_water", refill_amount))
	if not did_refill:
		return

	AudioManager.play_sfx("water_refill")
	bottles_left = maxi(bottles_left - 1, 0)
	_refresh_bottles_visual()

	_cooldown_left = maxf(refill_cooldown, 0.0)
	if _player.has_method("start_sink_fill_feedback"):
		_player.call("start_sink_fill_feedback", _cooldown_left)

	get_viewport().set_input_as_handled()


func _refresh_bottles_visual() -> void:
	# The texture is a 64x256 sheet: frame 0 = 4 bottles, 1 = 3, 2 = 2, 3 = 1.
	# Each used refill removes one bottle by advancing one frame.
	if _sprite == null:
		return
	if bottles_left <= 0:
		_sprite.visible = false
		return
	_sprite.visible = true
	_sprite.region_enabled = true
	var frame := clampi(starting_bottles - bottles_left, 0, 3)
	_sprite.region_rect = Rect2(0, frame * 64, 64, 64)


func _on_body_entered(body: Node) -> void:
	if body == null:
		return
	if body.name != "Player":
		return
	_player_in_range = true
	_player = body as Node2D


func _on_body_exited(body: Node) -> void:
	if body == null:
		return
	if body != _player:
		return
	_player_in_range = false
	_player = null
