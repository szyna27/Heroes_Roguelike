class_name EnemyGroup
extends Node2D

@onready var highlights = $"../../Tile highlights"
@onready var units = get_parent()

const UNIT = preload("res://src/unit/unit.tscn")

var units_alive: Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func spawn_units(count: int):
	for i in range(count):
		var unit = UNIT.instantiate()
		units_alive.append(unit)
		add_child(unit)
		unit.set_health_bar_color("red")
		unit.set_stats({
			"max_hp": 1,
			"hp": 1,
			"unit_count": 10,
			"damage": 1,
			"attack": 1,
			"defense": 1,
			"speed": 3,
			"ranged": false
		})
		unit.position = Vector2((Global.MAP_SIZE.x - 1) * Global.TILE_SIZE, i * Global.TILE_SIZE)
		unit.current_tile = Vector2i((Global.MAP_SIZE.x - 1), i)

func get_unit_at_tile(tile: Vector2i) -> Unit:
	for unit in get_children():
		if unit.current_tile == tile:
			return unit
	return null

func atack_unit(tile: Dictionary, unit: Unit) -> void:
	var attacked_unit = units.get_unit_at_tile(tile["position"])
	if attacked_unit:
		attacked_unit.take_damage(unit.damage * (1 + unit.attack * 0.05))
		if unit.unit_count <= 0:
			units_alive.erase(unit)
			unit.queue_free()
