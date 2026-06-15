extends Area2D


@export var heal_amount: int = 30

var _player_in_range: bool = false
var _player: Node2D = null


@onready var _sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	_sprite.texture = MedkitVisuals.get_texture()

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _unhandled_input(event: InputEvent) -> void:
	if not _player_in_range or _player == null:
		return

	if event is InputEventKey and event.echo:
		return

	if not event.is_action_pressed("interact"):
		return

	if not is_instance_valid(_player):
		return

	var healed := false
	if _player.has_method("heal"):
		healed = bool(_player.call("heal", heal_amount))
	elif _player.has_method("heal_one_heart"):
		healed = bool(_player.call("heal_one_heart"))

	if healed:
		AudioManager.play_sfx("pickup_medkit")
		get_viewport().set_input_as_handled()
		queue_free()


func _on_body_entered(body: Node) -> void:
	if body == null:
		return
	if body.name != "Player":
		return
	_player_in_range = true
	_player = body as Node2D


func _on_body_exited(body: Node) -> void:
	if body == null:
		return
	if body != _player:
		return
	_player_in_range = false
	_player = null
