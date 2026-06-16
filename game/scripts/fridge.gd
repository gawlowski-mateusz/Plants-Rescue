extends Area2D


const BEER_DIALOG_SCENE: PackedScene = preload("res://scenes/boss_reward_dialog.tscn")

@export var beer_pickup_scene: PackedScene = preload("res://scenes/beer_pickup.tscn")
@export var beer_amount: int = 6
@export var spawn_point_path: NodePath = NodePath("../BeerSpawnPoint")

var _player_in_range: bool = false
var _player: Node2D = null
var _has_spawned: bool = false
var _prompt: InteractionPrompt = null


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	_prompt = InteractionPrompt.new()
	add_child(_prompt)
	_prompt.set_text("E — otwórz lodówkę")


func _unhandled_input(event: InputEvent) -> void:
	if _has_spawned:
		return
	if not _player_in_range or _player == null:
		return

	if event is InputEventKey and event.echo:
		return
	if not event.is_action_pressed("interact"):
		return

	_spawn_beer_pickup()
	if _prompt != null:
		_prompt.hide_prompt()
	get_viewport().set_input_as_handled()


func _spawn_beer_pickup() -> void:
	if beer_pickup_scene == null:
		return

	var root := get_tree().current_scene
	if root == null:
		return

	var spawn_node := get_node_or_null(spawn_point_path) as Node2D
	var spawn_pos := global_position
	if spawn_node != null:
		spawn_pos = spawn_node.global_position

	var container := root.get_node_or_null("Pickups")
	if container == null:
		container = root

	var beer := beer_pickup_scene.instantiate()
	if beer == null:
		return

	container.add_child(beer)
	beer.global_position = spawn_pos
	if beer.has_method("set"):
		beer.set("beer_amount", beer_amount)

	_has_spawned = true
	_show_beer_dialog()


func _show_beer_dialog() -> void:
	if BEER_DIALOG_SCENE == null:
		return
	var root := get_tree().current_scene
	if root == null:
		return
	var dialog := BEER_DIALOG_SCENE.instantiate()
	if dialog == null:
		return
	var overlays := root.get_node_or_null("Overlays")
	if overlays != null:
		overlays.add_child(dialog)
	else:
		root.add_child(dialog)
	if dialog.has_signal("closed"):
		dialog.closed.connect(dialog.queue_free)
	if dialog.has_method("show_reward"):
		var body := (
				"W lodówce kryła się zgrzewka z " + str(beer_amount) + " piwami.\n"
				+ "Piwo przyspiesza ruch o 50% przez 10 sekund.\n"
				+ "Użyj klawiszem Q.")
		dialog.call("show_reward", "Znaleziono zgrzewkę piwa!", body)


func _on_body_entered(body: Node) -> void:
	if body == null:
		return
	if body.name != "Player":
		return
	_player_in_range = true
	_player = body as Node2D
	if _prompt != null and not _has_spawned:
		_prompt.show_prompt()


func _on_body_exited(body: Node) -> void:
	if body == null:
		return
	if body != _player:
		return
	_player_in_range = false
	_player = null
	if _prompt != null:
		_prompt.hide_prompt()
