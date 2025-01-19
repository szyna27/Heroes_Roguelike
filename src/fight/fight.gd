extends Node

@onready var fight_generator = $"Fight generator"
@onready var tile_map_layer = $"TileMapLayer"
@onready var tile_highlights = $"Tile highlights"
@onready var units = $"Units"

# Called when the node enters the scene tree for the first time.
func _ready():
	units.start_fight()
