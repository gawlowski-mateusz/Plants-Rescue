extends RefCounted
class_name MedkitVisuals


static var _cached_texture: Texture2D = null


static func get_texture() -> Texture2D:
	if _cached_texture != null:
		return _cached_texture

	var image := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))

	var outline := Color(0.10, 0.06, 0.03, 1.0)
	var body := Color(0.96, 0.92, 0.88, 1.0)
	var body_shadow := Color(0.86, 0.82, 0.78, 1.0)
	var cross := Color(0.92, 0.20, 0.25, 1.0)

	# Box outline
	for x in range(3, 13):
		_set_px(image, x, 4, outline)
		_set_px(image, x, 12, outline)
	for y in range(5, 12):
		_set_px(image, 3, y, outline)
		_set_px(image, 12, y, outline)

	# Box fill
	for y in range(5, 12):
		for x in range(4, 12):
			_set_px(image, x, y, body_shadow if y >= 10 else body)

	# Red cross
	for y in range(6, 11):
		_set_px(image, 7, y, cross)
		_set_px(image, 8, y, cross)
	for x in range(6, 10):
		_set_px(image, x, 8, cross)
		_set_px(image, x, 9, cross)

	_cached_texture = ImageTexture.create_from_image(image)
	return _cached_texture


static func _set_px(image: Image, x: int, y: int, color: Color) -> void:
	if x < 0 or y < 0 or x >= image.get_width() or y >= image.get_height():
		return
	image.set_pixel(x, y, color)
