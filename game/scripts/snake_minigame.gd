extends Control

## Secret unlockable mini-game: a snake that eats plants. Grid based, rendered
## with _draw(). Unlocked from the level-select once every level is completed.

const COLS: int = 21
const ROWS: int = 13
const CELL: int = 36
const TICK: float = 0.13

const TOP_MARGIN: float = 96.0
const BOTTOM_MARGIN: float = 60.0

const PLANT_TEX: Texture2D = preload("res://assets/images/plant_friendly.png")
# First frame of the friendly-plant sheet (same region the main menu uses).
const PLANT_REGION: Rect2 = Rect2(0, 0, 72, 72)

@onready var score_label: Label = %ScoreLabel
@onready var game_over_panel: Control = %GameOverPanel
@onready var final_score_label: Label = %FinalScoreLabel
@onready var restart_btn: Button = %RestartBtn
@onready var menu_btn: Button = %MenuBtn
@onready var top_back_btn: Button = %TopBackBtn
@onready var tick_timer: Timer = $TickTimer

var snake: Array[Vector2i] = []
var dir: Vector2i = Vector2i.RIGHT
var next_dir: Vector2i = Vector2i.RIGHT
var food: Vector2i = Vector2i.ZERO
var score: int = 0
var playing: bool = false
var board_origin: Vector2 = Vector2.ZERO


func _ready() -> void:
	restart_btn.pressed.connect(_start)
	menu_btn.pressed.connect(_back_to_menu)
	top_back_btn.pressed.connect(_back_to_menu)
	tick_timer.wait_time = TICK
	tick_timer.timeout.connect(_on_tick)
	resized.connect(_recompute_board)
	_recompute_board()
	AudioManager.play_music("menu_theme")
	_start()


func _recompute_board() -> void:
	var view := get_viewport_rect().size
	var bw := float(COLS * CELL)
	var bh := float(ROWS * CELL)
	var avail_h := view.y - TOP_MARGIN - BOTTOM_MARGIN
	board_origin = Vector2((view.x - bw) * 0.5, TOP_MARGIN + maxf(0.0, (avail_h - bh) * 0.5))
	queue_redraw()


func _start() -> void:
	var cx := COLS / 2
	var cy := ROWS / 2
	snake = [Vector2i(cx, cy), Vector2i(cx - 1, cy), Vector2i(cx - 2, cy)]
	dir = Vector2i.RIGHT
	next_dir = Vector2i.RIGHT
	score = 0
	playing = true
	game_over_panel.visible = false
	_spawn_food()
	_update_score()
	tick_timer.start()
	queue_redraw()


# ---------------------------------------------------------------
# INPUT
# ---------------------------------------------------------------

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_back_to_menu()
		return
	if not playing:
		return
	if event.is_action_pressed("up") or event.is_action_pressed("ui_up"):
		_try_set_dir(Vector2i.UP)
	elif event.is_action_pressed("down") or event.is_action_pressed("ui_down"):
		_try_set_dir(Vector2i.DOWN)
	elif event.is_action_pressed("left") or event.is_action_pressed("ui_left"):
		_try_set_dir(Vector2i.LEFT)
	elif event.is_action_pressed("right") or event.is_action_pressed("ui_right"):
		_try_set_dir(Vector2i.RIGHT)


func _try_set_dir(d: Vector2i) -> void:
	# Can't immediately reverse onto itself.
	if d == -dir:
		return
	next_dir = d


# ---------------------------------------------------------------
# GAME LOOP
# ---------------------------------------------------------------

func _on_tick() -> void:
	if not playing:
		return
	dir = next_dir
	var head: Vector2i = snake[0] + dir

	if head.x < 0 or head.y < 0 or head.x >= COLS or head.y >= ROWS:
		_game_over()
		return

	var will_grow := head == food
	# The tail vacates its cell unless we grow, so moving into it is allowed.
	var blocked := snake.slice(0, snake.size() if will_grow else snake.size() - 1)
	if head in blocked:
		_game_over()
		return

	snake.insert(0, head)
	if will_grow:
		score += 1
		_update_score()
		AudioManager.play_sfx("snake_eat")
		_spawn_food()
	else:
		snake.pop_back()
	queue_redraw()


func _spawn_food() -> void:
	var free_cells: Array[Vector2i] = []
	for x in COLS:
		for y in ROWS:
			var c := Vector2i(x, y)
			if not (c in snake):
				free_cells.append(c)
	if free_cells.is_empty():
		# Board full — the player has perfectly cleared it.
		_game_over()
		return
	food = free_cells[randi() % free_cells.size()]


func _game_over() -> void:
	playing = false
	tick_timer.stop()
	AudioManager.play_sfx("snake_over")
	final_score_label.text = "Wynik: %d" % score
	game_over_panel.visible = true


func _update_score() -> void:
	score_label.text = "Wynik: %d" % score


func _back_to_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


# ---------------------------------------------------------------
# RENDER
# ---------------------------------------------------------------

func _draw() -> void:
	# Full-window background (drawn here so it sits *behind* the board; a child
	# ColorRect would instead render on top of _draw and hide everything).
	draw_rect(Rect2(Vector2.ZERO, get_viewport_rect().size), Color(0.08, 0.05, 0.04, 1.0), true)

	var bw := float(COLS * CELL)
	var bh := float(ROWS * CELL)
	var board_rect := Rect2(board_origin, Vector2(bw, bh))

	draw_rect(board_rect, Color(0.07, 0.12, 0.06, 1.0), true)

	# Subtle grid lines.
	var grid_col := Color(1, 1, 1, 0.05)
	for x in range(COLS + 1):
		var gx := board_origin.x + float(x * CELL)
		draw_line(Vector2(gx, board_origin.y), Vector2(gx, board_origin.y + bh), grid_col, 1.0)
	for y in range(ROWS + 1):
		var gy := board_origin.y + float(y * CELL)
		draw_line(Vector2(board_origin.x, gy), Vector2(board_origin.x + bw, gy), grid_col, 1.0)

	# Food (a plant to eat).
	var food_pos := board_origin + Vector2(float(food.x * CELL), float(food.y * CELL))
	draw_texture_rect_region(PLANT_TEX,
			Rect2(food_pos + Vector2(2, 2), Vector2(CELL - 4, CELL - 4)), PLANT_REGION)

	# Snake.
	for i in range(snake.size()):
		var seg := snake[i]
		var p := board_origin + Vector2(float(seg.x * CELL), float(seg.y * CELL))
		var col := Color(0.18, 0.55, 0.2) if i == 0 else Color(0.32, 0.8, 0.34)
		draw_rect(Rect2(p + Vector2(2, 2), Vector2(CELL - 4, CELL - 4)), col, true)

	# Board border on top.
	draw_rect(board_rect, Color(0.85, 0.7, 0.3, 1.0), false, 3.0)
