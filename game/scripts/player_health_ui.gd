extends Control


const HEART_COUNT: int = 3
const HEALTH_PER_HEART: int = 30
const MAX_HEALTH: int = HEART_COUNT * HEALTH_PER_HEART

const HEART_WIDTH: int = 7
const HEART_HEIGHT: int = 6
const PIXEL_SIZE: float = 6.0
const HEART_SPACING: float = 8.0
const DRAW_OFFSET_X: float = 10.0
const DRAW_OFFSET_Y: float = 36.0

const HEART_ROWS := [
	"0110110",
	"1111111",
	"1111111",
	"0111110",
	"0011100",
	"0001000"
]

const FILLED_COLOR := Color(0.94902, 0.32549, 0.439216, 1.0)
const EMPTY_COLOR := Color(0.247059, 0.160784, 0.2, 1.0)

var current_health: int = MAX_HEALTH


func _ready() -> void:
	var total_width := (HEART_COUNT * HEART_WIDTH * PIXEL_SIZE) + ((HEART_COUNT - 1) * HEART_SPACING)
	custom_minimum_size = Vector2(total_width, HEART_HEIGHT * PIXEL_SIZE)


func _draw() -> void:
	for heart_index in range(HEART_COUNT):
		_draw_heart(heart_index)


func _draw_heart(heart_index: int) -> void:
	var heart_offset_x := heart_index * ((HEART_WIDTH * PIXEL_SIZE) + HEART_SPACING)
	var segment_health := clampi(current_health - (heart_index * HEALTH_PER_HEART), 0, HEALTH_PER_HEART)
	var fill_ratio := float(segment_health) / float(HEALTH_PER_HEART)
	var filled_columns := int(floor(fill_ratio * HEART_WIDTH))

	for y in range(HEART_HEIGHT):
		var row: String = HEART_ROWS[y]
		for x in range(HEART_WIDTH):
			if row.substr(x, 1) != "1":
				continue

			var pixel_pos := Vector2(DRAW_OFFSET_X + heart_offset_x + (x * PIXEL_SIZE), DRAW_OFFSET_Y + y * PIXEL_SIZE)
			var pixel_rect := Rect2(pixel_pos, Vector2(PIXEL_SIZE, PIXEL_SIZE))
			var pixel_color := FILLED_COLOR if x < filled_columns else EMPTY_COLOR
			draw_rect(pixel_rect, pixel_color, true)


func set_health(new_health: int, max_health: int = MAX_HEALTH) -> void:
	var clamped_max_health: int = max_health if max_health > 0 else 1
	current_health = clampi(new_health, 0, clamped_max_health)
	queue_redraw()


func _on_player_health_changed(current: int, max_health: int) -> void:
	set_health(current, max_health)
