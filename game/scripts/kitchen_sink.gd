extends Area2D


@export var refill_amount: int = 25
@export var refill_cooldown: float = 1.0

var _player_in_range: bool = false
var _player: Node2D = null
var _cooldown_left: float = 0.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(delta: float) -> void:
	if _cooldown_left > 0.0:
		_cooldown_left = max(_cooldown_left - delta, 0.0)


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
	if _cooldown_left > 0.0:
		return
	if event is InputEventKey and (event as InputEventKey).echo:
		return

	if not event.is_action_pressed("interact"):
		return

	if _player.has_method("refill_water"):
		var did_refill = _player.call("refill_water", refill_amount)
		if did_refill:
			_cooldown_left = refill_cooldown
			if _player.has_method("start_sink_fill_feedback"):
				_player.call("start_sink_fill_feedback", refill_cooldown)
