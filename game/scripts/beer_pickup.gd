extends Area2D


@export var beer_amount: int = 6

var _player_in_range: bool = false
var _player: Node2D = null
var _prompt: InteractionPrompt = null

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	if sprite != null:
		sprite.texture = BeerVisuals.get_beer_texture()
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	_prompt = InteractionPrompt.new()
	add_child(_prompt)
	_prompt.set_text("E — weź piwo\n(Q, aby wypić: przyspieszenie)")


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		_player_in_range = true
		_player = body
		if _prompt != null:
			_prompt.show_prompt()


func _on_body_exited(body: Node2D) -> void:
	if body == _player:
		_player_in_range = false
		_player = null
		if _prompt != null:
			_prompt.hide_prompt()


func _unhandled_input(event: InputEvent) -> void:
	if not _player_in_range or _player == null:
		return
	if event is InputEventKey and (event as InputEventKey).echo:
		return
	if not event.is_action_pressed("interact"):
		return

	if _player.has_method("add_beer"):
		_player.call("add_beer", beer_amount)
		AudioManager.play_sfx("pickup_beer")
		queue_free()
