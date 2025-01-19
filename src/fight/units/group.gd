class_name Group
extends Node2D

@onready var highlights = $"../../Tile highlights"
@onready var units = get_parent()

const UNIT = preload("res://src/unit/unit.tscn")
var units_alive: Array = []

func spawn_units(count: int):
    for i in range(count):
        var unit = UNIT.instantiate()
        units_alive.append(unit)
        add_child(unit)
        unit.set_health_bar_color(get_color())
        unit.set_stats(get_random_stats())
        unit.position = get_unit_position(i)
        unit.current_tile = get_tile(i)

func get_random_stats() -> Dictionary:
    var hp = randi() % 90 + 10
    var stats = {
        "max_hp": hp,
        "hp": hp,
        "unit_count": randi() % 99 + 1,
        "damage": randi() % 9 + 1,
        "attack": randi() % 19 + 1,
        "defense": randi() % 19 + 1,
        "speed": randi() % 12 + 3,
        "ranged": randi() % 2 == 0
    }
    return stats

func get_color() -> String:
    assert(false, "get_color() must be implemented in derived classes")
    return ""

func get_unit_position(_i: int) -> Vector2:
    assert(false, "get_position() must be implemented in derived classes")
    return Vector2()

func get_tile(_i: int) -> Vector2i:
    assert(false, "get_tile() must be implemented in derived classes")
    return Vector2i()

func get_unit_at_tile(tile: Vector2i) -> Unit:
    for unit in get_children():
        if unit.current_tile == tile:
            return unit
    return null

func atack_unit(tile: Dictionary, unit: Unit) -> void:
    var attacked_unit = units.get_unit_at_tile(tile["position"])
    if attacked_unit:
        if attacked_unit.defense < unit.attack:
            attacked_unit.take_damage(int(unit.unit_count * unit.damage * (1 + unit.attack * 0.05)))
        else:
            attacked_unit.take_damage(int(unit.unit_count * unit.damage * (1 - attacked_unit.defense * 0.03)))
