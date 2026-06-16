extends Control

## Edge-of-screen arrow pointing toward the nearest un-rescued plant when it is
## outside the camera view (extension of the wayfinding cue, Nielsen H1/H6).
## Self-contained: finds the player and the "unrescued_plants" group on its own.

const EDGE_MARGIN: float = 60.0          # distance from the screen edge
const ARROW_SIZE: float = 26.0
const ARROW_COLOR: Color = Color(0.6, 0.95, 0.45, 0.95)   # friendly green
const ARROW_OUTLINE: Color = Color(0.05, 0.15, 0.0, 0.9)

var _player: Node2D = null
var _arrow_pos: Vector2 = Vector2.ZERO
var _arrow_dir: Vector2 = Vector2.RIGHT
var _show_arrow: bool = false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func set_player(p: Node2D) -> void:
	_player = p


func _process(_delta: float) -> void:
	_update_target()
	queue_redraw()


func _update_target() -> void:
	_show_arrow = false

	if _player == null or not is_instance_valid(_player):
		var scene := get_tree().current_scene
		if scene != null:
			_player = scene.get_node_or_null("Player") as Node2D
	if _player == null:
		return
	# Hide while the player can't act (intro hand-off, game over, completion).
	if bool(_player.get("input_locked")):
		return

	var plants := get_tree().get_nodes_in_group("unrescued_plants")
	if plants.is_empty():
		return

	var ppos: Vector2 = _player.global_position
	var nearest: Node2D = null
	var best: float = INF
	for p in plants:
		if not is_instance_valid(p):
			continue
		var n2 := p as Node2D
		if n2 == null:
			continue
		var d: float = ppos.distance_squared_to(n2.global_position)
		if d < best:
			best = d
			nearest = n2
	if nearest == null:
		return

	var vp_size: Vector2 = get_viewport_rect().size
	var ct: Transform2D = get_viewport().get_canvas_transform()
	var screen_pos: Vector2 = ct * nearest.global_position

	var rect := Rect2(Vector2(EDGE_MARGIN, EDGE_MARGIN), vp_size - Vector2(EDGE_MARGIN, EDGE_MARGIN) * 2.0)
	if rect.has_point(screen_pos):
		return  # on-screen -> no arrow needed

	var center: Vector2 = vp_size * 0.5
	_arrow_pos = Vector2(
		clampf(screen_pos.x, rect.position.x, rect.position.x + rect.size.x),
		clampf(screen_pos.y, rect.position.y, rect.position.y + rect.size.y))
	var dir: Vector2 = screen_pos - center
	_arrow_dir = dir.normalized() if dir.length() > 1.0 else Vector2.RIGHT
	_show_arrow = true


func _draw() -> void:
	if not _show_arrow:
		return

	var t := Transform2D(_arrow_dir.angle(), _arrow_pos)
	var local := PackedVector2Array([
		Vector2(ARROW_SIZE, 0.0),
		Vector2(-ARROW_SIZE * 0.7, ARROW_SIZE * 0.7),
		Vector2(-ARROW_SIZE * 0.7, -ARROW_SIZE * 0.7),
	])
	var pts := PackedVector2Array()
	for p in local:
		pts.append(t * p)

	draw_colored_polygon(pts, ARROW_COLOR)
	var outline := pts
	outline.append(pts[0])
	draw_polyline(outline, ARROW_OUTLINE, 2.0)
