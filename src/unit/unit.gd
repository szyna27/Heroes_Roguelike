class_name Unit
extends Node2D

@export var current_tile: Vector2i
@export var max_hp: int
@export var hp: int
@export var unit_count: int
@export var damage: int
@export var attack: int
@export var defense: int
@export var speed: int
@export var ranged: bool

@onready var health_bar: Node2D = $"Health bar"
@onready var parent_node: Node2D = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func set_health_bar_color(color: String) -> void:
	health_bar.set_bar_color(color)

func set_stats(kwargs: Dictionary) -> void:
	max_hp = kwargs["max_hp"]
	hp = kwargs["hp"]
	unit_count = kwargs["unit_count"]
	damage = kwargs["damage"]
	attack = kwargs["attack"]
	defense = kwargs["defense"]
	speed = kwargs["speed"]
	ranged = kwargs["ranged"]
	health_bar.update_unit_count(unit_count)

func take_damage(damage_amount: int) -> void:
	while damage_amount > 0 and unit_count >= 0:
		if hp > damage_amount:
			hp -= damage_amount
			damage_amount = 0
		else:
			damage_amount -= hp
			unit_count -= 1
			hp = max_hp

	if unit_count <= 0:
		Global.unit_dead.emit(self)
	else:
		health_bar.update_unit_count(unit_count)

func move(tile_position: Vector2, end_turn = true) -> void:
	position = tile_position * Global.TILE_SIZE
	current_tile = tile_position
	
	if end_turn:
		Global.turn_finished.emit()

func attack_unit(tile: Dictionary) -> void:
	move(tile["position"] + tile["side"], false)
	parent_node.atack_unit(tile, self)
	Global.turn_finished.emit()
