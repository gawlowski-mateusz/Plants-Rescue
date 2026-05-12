extends Control


const VINE_ID := "vine"
const MUSHROOM_ID := "mushroom"
const PALM_ID := "palm"


@onready var vine_icon: TextureRect = $Panel/VBox/Vine/Icon
@onready var vine_label: Label = $Panel/VBox/Vine/Label
@onready var mushroom_icon: TextureRect = $Panel/VBox/Mushroom/Icon
@onready var mushroom_label: Label = $Panel/VBox/Mushroom/Label
@onready var palm_icon: TextureRect = $Panel/VBox/Palm/Icon
@onready var palm_label: Label = $Panel/VBox/Palm/Label


func _ready() -> void:
	vine_icon.texture = BossTrophyVisuals.get_vine_texture()
	mushroom_icon.texture = BossTrophyVisuals.get_mushroom_texture()
	palm_icon.texture = BossTrophyVisuals.get_palm_texture()

	vine_label.text = "Zasięg+"
	mushroom_label.text = "+1 serce"
	palm_label.text = "Trofeum"

	_refresh_from_game_state()
	_update_root_visibility()


func unlock_trophy(boss_id: String) -> void:
	var target: Control = null
	match boss_id:
		VINE_ID:
			target = $Panel/VBox/Vine
		MUSHROOM_ID:
			target = $Panel/VBox/Mushroom
		PALM_ID:
			target = $Panel/VBox/Palm
		_:
			return

	if target.visible:
		return

	visible = true
	target.visible = true
	_emit_trophy(target)


func _refresh_from_game_state() -> void:
	$Panel/VBox/Vine.visible = false
	$Panel/VBox/Mushroom.visible = false
	$Panel/VBox/Palm.visible = false

	var gs := get_node_or_null("/root/GameState")
	if gs == null:
		return

	if bool(gs.get("boss_vine_defeated")):
		$Panel/VBox/Vine.visible = true
	if bool(gs.get("boss_mushroom_defeated")):
		$Panel/VBox/Mushroom.visible = true
	if bool(gs.get("boss_palm_defeated")):
		$Panel/VBox/Palm.visible = true

	_update_root_visibility()


func _update_root_visibility() -> void:
	visible = $Panel/VBox/Vine.visible or $Panel/VBox/Mushroom.visible or $Panel/VBox/Palm.visible


func _emit_trophy(node: Control) -> void:
	node.modulate = Color(1, 1, 1, 0.0)
	node.scale = Vector2(1.15, 1.15)
	var t := create_tween()
	t.tween_property(node, "modulate:a", 1.0, 0.18)
	t.parallel().tween_property(node, "scale", Vector2.ONE, 0.22)
