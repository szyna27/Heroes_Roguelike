class_name EnemyGroup
extends Group

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func get_color() -> String:
	return "red"

func get_unit_position(i: int) -> Vector2:
	return Vector2((Global.MAP_SIZE.x - 1) * Global.TILE_SIZE, i * Global.TILE_SIZE)

func get_tile(i: int) -> Vector2i:
	return Vector2i((Global.MAP_SIZE.x - 1), i)
