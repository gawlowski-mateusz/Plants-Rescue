extends Area2D


@export var beer_amount: int = 6

var _player_in_range: bool = false
var _player: Node2D = null

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	if sprite != null:
		sprite.texture = BeerVisuals.get_beer_texture()
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		_player_in_range = true
		_player = body


func _on_body_exited(body: Node2D) -> void:
	if body == _player:
		_player_in_range = false
		_player = null


func _unhandled_input(event: InputEvent) -> void:
	if not _player_in_range or _player == null:
		return

	if not (event is InputEventKey):
		return

	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return

	if key_event.physical_keycode != KEY_SPACE:
		return

	if _player.has_method("add_beer"):
		_player.call("add_beer", beer_amount)
		queue_free()
