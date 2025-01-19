class_name PlayerGroup
extends Group

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func get_color() -> String:
	return "blue"

func get_unit_position(i: int) -> Vector2:
	return Vector2(0, i * Global.TILE_SIZE)

func get_tile(i: int) -> Vector2i:
	return Vector2i(0, i)
