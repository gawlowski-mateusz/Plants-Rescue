extends RefCounted
class_name BeerVisuals


static var _cached_beer_texture: Texture2D = null


static func get_beer_texture() -> Texture2D:
	if _cached_beer_texture != null:
		return _cached_beer_texture

	var image := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))

	var outline := Color(0.10, 0.06, 0.03, 1.0)
	var beer := Color(0.95, 0.78, 0.22, 1.0)
	var beer_dark := Color(0.86, 0.64, 0.18, 1.0)
	var foam := Color(1.0, 1.0, 0.92, 1.0)
	var highlight := Color(1.0, 0.90, 0.55, 1.0)

	# Top foam
	_set_px(image, 4, 4, outline)
	_set_px(image, 11, 4, outline)
	for x in range(5, 11):
		_set_px(image, x, 4, foam)

	# Mug body
	for y in range(5, 13):
		_set_px(image, 4, y, outline)
		_set_px(image, 11, y, outline)
		for x in range(5, 11):
			var c := beer
			if x == 5 and y < 12:
				c = highlight
			elif y >= 11:
				c = beer_dark
			_set_px(image, x, y, c)

	# Bottom
	for x in range(4, 12):
		_set_px(image, x, 13, outline)

	# Handle
	for y in range(7, 12):
		_set_px(image, 12, y, outline)
	for y in range(8, 11):
		_set_px(image, 13, y, outline)

	_cached_beer_texture = ImageTexture.create_from_image(image)
	return _cached_beer_texture


static func _set_px(image: Image, x: int, y: int, color: Color) -> void:
	if x < 0 or y < 0 or x >= image.get_width() or y >= image.get_height():
		return
	image.set_pixel(x, y, color)
