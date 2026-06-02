extends RefCounted
class_name MedkitVisuals


static var _cached_texture: Texture2D = null


static func get_texture() -> Texture2D:
	if _cached_texture != null:
		return _cached_texture

	_cached_texture = load("res://assets/images/pickups/medkit.png")
	return _cached_texture


static func _set_px(image: Image, x: int, y: int, color: Color) -> void:
	if x < 0 or y < 0 or x >= image.get_width() or y >= image.get_height():
		return
	image.set_pixel(x, y, color)
