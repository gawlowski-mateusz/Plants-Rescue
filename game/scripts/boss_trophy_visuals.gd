extends RefCounted
class_name BossTrophyVisuals


static var _vine: Texture2D = null
static var _mushroom: Texture2D = null
static var _palm: Texture2D = null


static func get_vine_texture() -> Texture2D:
	if _vine == null:
		_vine = _make_trophy(Color(0.35, 0.85, 0.45, 1.0), Color(0.18, 0.55, 0.25, 1.0))
	return _vine


static func get_mushroom_texture() -> Texture2D:
	if _mushroom == null:
		_mushroom = _make_trophy(Color(0.82, 0.45, 0.95, 1.0), Color(0.55, 0.25, 0.75, 1.0))
	return _mushroom


static func get_palm_texture() -> Texture2D:
	if _palm == null:
		_palm = _make_trophy(Color(0.96, 0.78, 0.22, 1.0), Color(0.75, 0.52, 0.14, 1.0))
	return _palm


static func _make_trophy(main: Color, shadow: Color) -> Texture2D:
	var image := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))

	var outline := Color(0.10, 0.06, 0.03, 1.0)

	# Cup top outline
	for x in range(4, 12):
		_set_px(image, x, 3, outline)
	# Cup sides
	for y in range(4, 9):
		_set_px(image, 4, y, outline)
		_set_px(image, 11, y, outline)
	# Cup fill
	for y in range(4, 9):
		for x in range(5, 11):
			_set_px(image, x, y, shadow if y >= 7 else main)

	# Handles
	_set_px(image, 3, 5, outline)
	_set_px(image, 3, 6, outline)
	_set_px(image, 12, 5, outline)
	_set_px(image, 12, 6, outline)

	# Stem
	for y in range(9, 12):
		_set_px(image, 7, y, outline)
		_set_px(image, 8, y, outline)
		_set_px(image, 7, y, main)
		_set_px(image, 8, y, shadow)

	# Base
	for x in range(5, 11):
		_set_px(image, x, 12, outline)
		_set_px(image, x, 13, outline)
	for y in range(12, 14):
		for x in range(6, 10):
			_set_px(image, x, y, shadow)

	return ImageTexture.create_from_image(image)


static func _set_px(image: Image, x: int, y: int, color: Color) -> void:
	if x < 0 or y < 0 or x >= image.get_width() or y >= image.get_height():
		return
	image.set_pixel(x, y, color)
