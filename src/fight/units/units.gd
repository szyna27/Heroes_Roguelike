extends Node2D

@onready var player_group = $"Player group"
@onready var enemy_group = $"Enemy group"

var player_turn: bool
var turn_order: Array

signal player_turn_started
signal player_turn_ended
# signal enemy_turn_started
# signal enemy_turn_ended

# Called when the node enters the scene tree for the first time.
func _ready():
	player_group.spawn_units(6)
	enemy_group.spawn_units(6)
	Global.unit_dead.connect(_on_unit_death)

func start_fight():
	while true:
		print(player_group.get_children().size())
		print(enemy_group.get_children().size())
		if player_group.get_children().size() == 0:
			print("Enemy wins")
			break
		elif enemy_group.get_children().size() == 0:
			print("Player wins")
			break
		else:
			await start_round()

func start_round():
	# Sort units by speed
	for unit in player_group.get_children():
		turn_order.append({"instance": unit, "type": "player"})
	for unit in enemy_group.get_children():
		turn_order.append({"instance": unit, "type": "enemy"})

	turn_order.sort_custom(_sort_units)
	for i in turn_order:
		print(i["instance"].name + " " + str(i["instance"].speed))

	for unit in turn_order:
		if unit["type"] == "player":
			player_turn_started.emit(unit["instance"])
			await Global.turn_finished
			player_turn_ended.emit()
		else:
			player_turn_started.emit(unit["instance"])
			await Global.turn_finished
			player_turn_ended.emit()

	turn_order.clear()

func get_unit_at_tile(tile: Vector2i) -> Unit:
	var unit = player_group.get_unit_at_tile(tile)
	if unit:
		return unit

	unit = enemy_group.get_unit_at_tile(tile)
	if unit:
		return unit

	return null

func _sort_units(a: Dictionary, b: Dictionary) -> bool:
	if a["instance"].speed < b["instance"].speed:
		return false
	else:
		return true


func _on_tile_selected(tile: Vector2i) -> Unit:
	if player_turn:
		var unit = player_group.get_unit_at_tile(tile)
		if unit:
			return unit
		
	return null

func _on_unit_death(unit: Unit) -> void:
	if unit in player_group.get_children():
		player_group.remove_child(unit)
	else:
		enemy_group.remove_child(unit)
	unit.queue_free()
	for dict in turn_order:
		if dict["instance"] == unit:
			turn_order.erase(dict)
			break
