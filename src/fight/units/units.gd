extends Node2D

@onready var player_group = $"Player group"
@onready var enemy_group = $"Enemy group"

var player_turn: bool

signal player_turn_started
signal player_turn_ended
# signal enemy_turn_started
# signal enemy_turn_ended

# Called when the node enters the scene tree for the first time.
func _ready():
	player_group.spawn_units(6)
	enemy_group.spawn_units(6)

func start_fight():
	while true:
		await start_round()

func start_round():
	var turn_order: Array = []
	# Sort units by speed
	for unit in player_group.get_children():
		turn_order.append({"instance": unit, "type": "player"})
	for unit in enemy_group.get_children():
		turn_order.append({"instance": unit, "type": "enemy"})

	turn_order.sort_custom(_sort_units)

	for unit in turn_order:
		if unit["type"] == "player":
			player_turn_started.emit(unit["instance"])
			await Global.turn_finished
			player_turn_ended.emit()
		else:
			player_turn_started.emit(unit["instance"])
			await Global.turn_finished
			player_turn_ended.emit()

func get_unit_at_tile(tile: Vector2i) -> Unit:
	var unit = player_group.get_unit_at_tile(tile)
	if unit:
		return unit

	unit = enemy_group.get_unit_at_tile(tile)
	if unit:
		return unit

	return null

func _sort_units(a: Dictionary, b: Dictionary) -> int:
	if a["instance"].speed > b["instance"].speed:
		return -1
	elif a["instance"].speed < b["instance"].speed:
		return 1
	else:
		return 0

func _on_tile_selected(tile: Vector2i) -> Unit:
	if player_turn:
		var unit = player_group.get_unit_at_tile(tile)
		if unit:
			return unit
		
	return null
