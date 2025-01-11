extends Node2D

@onready var player_group = $"Player group"
@onready var enemy_group = $"Enemy group"

# Called when the node enters the scene tree for the first time.
func _ready():
	player_group.spawn_units(8)
	enemy_group.spawn_units(8)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
