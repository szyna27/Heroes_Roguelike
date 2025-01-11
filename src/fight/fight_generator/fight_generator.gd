extends Node

@onready var units = $"../Units"
# Called when the node enters the scene tree for the first time.
func _ready():
	# Create a new unit
	var stats = {
		"max_hp": 1,
		"hp": 1,
		"unit_count": 10,
		"damage": 1,
		"attack": 1,
		"defense": 1,
		"speed": 3,
		"atack_range": 1
	}



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
