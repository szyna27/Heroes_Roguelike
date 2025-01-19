extends Node2D

@onready var highlights = $"../Tile highlights"
@onready var health = $Health
@onready var damage = $Damage
@onready var attack = $Attack
@onready var defense = $Defense
@onready var speed = $Speed
@onready var ranged = $Ranged

# Called when the node enters the scene tree for the first time.
func _ready():
	connect_signals()

func connect_signals() -> void:
	highlights.enter_unit.connect(_on_enter_unit)
	highlights.exit_unit.connect(_on_exit_unit)

func _on_enter_unit(unit: Node) -> void:
	health.text = "Health: " + str(unit.hp) + "/" + str(unit.max_hp)
	damage.text = "Damage: " + str(unit.damage)
	attack.text = "Attack: " + str(unit.attack)
	defense.text = "Defense: " + str(unit.defense)
	speed.text = "Speed: " + str(unit.speed)
	ranged.text = "Ranged: " + str(unit.ranged)

func _on_exit_unit() -> void:
	health.text = ""
	damage.text = ""
	attack.text = ""
	defense.text = ""
	speed.text = ""
	ranged.text = ""
