class_name Unit
extends Node2D

signal movement_complete
signal attack_begin(ac)
signal attack_complete(ac)
signal unit_damaged
signal unit_dead


@export var max_hp: int
@export var hp: int
@export var unit_count: int
@export var damage: int
@export var attack: int
@export var defense: int
@export var speed: int
@export var atack_range: int


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func set_stats(kwargs: Dictionary) -> void:
	max_hp = kwargs["max_hp"]
	hp = kwargs["hp"]
	unit_count = kwargs["unit_count"]
	damage = kwargs["damage"]
	attack = kwargs["attack"]
	defense = kwargs["defense"]
	speed = kwargs["speed"]
	atack_range = kwargs["atack_range"]
