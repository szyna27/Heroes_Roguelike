extends Node2D

const UNIT = preload("res://src/unit/unit.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func spawn_units(count: int):
	for i in range(count):
		var unit = UNIT.instantiate()
		add_child(unit)
		unit.set_stats({
			"max_hp": 1,
			"hp": 1,
			"unit_count": 10,
			"damage": 1,
			"attack": 1,
			"defense": 1,
			"speed": 3,
			"atack_range": 1
		})
		unit.position = Vector2(0, i * Global.TILE_SIZE)
