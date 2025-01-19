extends Node2D

var blue: Texture2D = load("res://src/unit/health_bar/hp_bar_blue.png")
var red: Texture2D = load("res://src/unit/health_bar/hp_bar_red.png")

@onready var background: Sprite2D = $Background
@onready var unit_count_label: Label = $"Unit amount label"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func set_bar_color(color: String) -> void:
	match color:
		"blue":
			background.texture = blue
		"red":
			background.texture = red
		_:
			pass

func update_unit_count(unit_count: int) -> void:
	unit_count_label.text = str(unit_count)
	
