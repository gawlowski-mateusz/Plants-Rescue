extends RefCounted
class_name BeerVisuals


static var _cached_beer_texture: Texture2D = null


static func get_beer_texture() -> Texture2D:
	if _cached_beer_texture != null:
		return _cached_beer_texture

	_cached_beer_texture = load("res://assets/images/pickups/beer_mug.png")
	return _cached_beer_texture


static func _set_px(image: Image, x: int, y: int, color: Color) -> void:
	if x < 0 or y < 0 or x >= image.get_width() or y >= image.get_height():
		return
	image.set_pixel(x, y, color)
