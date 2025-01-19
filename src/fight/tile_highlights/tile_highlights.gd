extends Node2D

@onready var highlight_texture: Texture2D = load("res://src/fight/tile_highlights/textures/highlight.png")
@onready var selected_texture: Texture2D = load("res://src/fight/tile_highlights/textures/selected.png")
@onready var movable_texture: Texture2D = load("res://src/fight/tile_highlights/textures/movable.png")
@onready var move_texture: Texture2D = load("res://src/fight/tile_highlights/textures/move.png")
@onready var attackable_texture: Texture2D = load("res://src/fight/tile_highlights/textures/attackable.png")
@onready var attack_textures: Dictionary = {
	Vector2(-1, 0): load("res://src/fight/tile_highlights/textures/attack_left.png"),
	Vector2(1, 0): load("res://src/fight/tile_highlights/textures/attack_right.png"),
	Vector2(0, -1): load("res://src/fight/tile_highlights/textures/attack_up.png"),
	Vector2(0, 1): load("res://src/fight/tile_highlights/textures/attack_down.png"),
}
@onready var units = $"../Units"

const TILE_OFFSET: Vector2 = Vector2(2, 2)
const PIXEL_OFFSET: Vector2 = Vector2(64, 96)
var current_tile_position: Vector2
var current_tile_side: Vector2
var current_tile_sprite: Sprite2D
var selected_tile: Sprite2D
var selected_unit: Unit
var movable_tiles_sprites: Array
var movable_tiles: Array
var attackable_tiles_sprites: Array
var attackable_tiles: Array
var active: bool = false

signal enter_unit(unit: Unit)
signal exit_unit

# Called when the node enters the scene tree for the first time.
func _ready():
	connect_signals()

# Detect which tile mouse is hovering over
func _input(event):
	if not active:
		return

	if event is InputEventMouseMotion:
		var tile = get_tile(event.position)
		if tile["position"] != current_tile_position or tile["side"] != current_tile_side:
			highlight_tile(tile)

	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			var tile = get_tile(event.position)
			if check_if_movable(tile["position"]):
				clear_move_attack_tiles()
				_deactivate()
				selected_unit.move(tile["position"])
			elif check_if_attackable(tile):
				clear_move_attack_tiles()
				_deactivate()
				selected_unit.attack_unit(tile)

# Highligth the tile
func highlight_tile(tile: Dictionary) -> void:
	delete_highlight()
	exit_unit.emit()
	current_tile_position = tile["position"]
	current_tile_side = tile["side"]
	if tile["position"].x < 0 or tile["position"].y < 0 or tile["position"].x >= Global.MAP_SIZE.x or tile["position"].y >= Global.MAP_SIZE.y:
		return

	if check_if_movable(tile["position"]) and tile["position"] != Vector2(selected_unit.current_tile):
		current_tile_sprite = Sprite2D.new()
		current_tile_sprite.texture = move_texture
		current_tile_sprite.position = tile["position"] * Global.TILE_SIZE

	elif check_if_attackable(tile):
		current_tile_sprite = Sprite2D.new()
		current_tile_sprite.texture = attack_textures[tile["side"]]
		current_tile_sprite.position = tile["position"] * Global.TILE_SIZE

	else:
		current_tile_sprite = Sprite2D.new()
		current_tile_sprite.texture = highlight_texture
		current_tile_sprite.position = tile["position"] * Global.TILE_SIZE
	add_child(current_tile_sprite)

	var focused_unit = units.get_unit_at_tile(tile["position"])
	if focused_unit:
		enter_unit.emit(focused_unit)

# Delete the highlight_texture
func delete_highlight():
	if current_tile_sprite:
		current_tile_sprite.queue_free()
		current_tile_sprite = null

# Select character
func select_character(tile_position: Vector2) -> bool:
	delete_selection()

	if tile_position.x < 0 or tile_position.y < 0 or tile_position.x >= Global.MAP_SIZE.x or tile_position.y >= Global.MAP_SIZE.y:
		return false

	selected_tile = Sprite2D.new()
	selected_tile.texture = selected_texture
	selected_tile.position = tile_position * Global.TILE_SIZE
	add_child(selected_tile)
	return true

# Delete the selected_texture tile
func delete_selection():
	if selected_tile:
		selected_tile.queue_free()
		selected_tile = null

# Get the tile position
func get_tile(hover_position: Vector2) -> Dictionary:
	var side: Vector2
	# Check which side of the tile the mouse is closest to
	var distances: Dictionary = {
		Vector2(-1, 0): int(hover_position.x + PIXEL_OFFSET.x) % Global.TILE_SIZE,
		Vector2(1, 0): Global.TILE_SIZE - int(hover_position.x + PIXEL_OFFSET.x) % Global.TILE_SIZE,
		Vector2(0, -1): int(hover_position.y + PIXEL_OFFSET.y) % Global.TILE_SIZE,
		Vector2(0, 1): Global.TILE_SIZE - int(hover_position.y + PIXEL_OFFSET.y) % Global.TILE_SIZE
	}

	for distance in distances:
		if side == Vector2(0, 0) or distances[distance] < distances[side]:
			side = distance

	var tile = {
		"position": Vector2(
			int((hover_position.x + PIXEL_OFFSET.x) / Global.TILE_SIZE) - TILE_OFFSET.x,
			int((hover_position.y + PIXEL_OFFSET.y) / Global.TILE_SIZE) - TILE_OFFSET.y
		),
		"side": side
	} 
	return tile

func search_move_attack_range(unit: Unit):
	var move_range = unit.speed
	var visited = {}
	var queue = []
	var start_tile = unit.current_tile

	# Start with the unit's tile for movable range calculation
	queue.append([start_tile, 0])  # (tile_position, distance)

	while queue.size() > 0:
		var current = queue.pop_front()
		var current_tile = current[0]
		var current_distance = current[1]

		# Skip if already visited
		if visited.has(current_tile):
			continue

		# Mark as visited
		visited[current_tile] = true

		# Mark tiles within move range as movable
		if current_distance <= move_range:
			if units.get_unit_at_tile(current_tile) == null:  # Skip tiles with units
				movable_tiles.append(current_tile)

		# Stop expanding the search beyond the move range
		if current_distance == move_range:
			continue

		# Check neighboring tiles (N, E, S, W)
		var neighbors = [
			current_tile + Vector2i(0, -1),  # North
			current_tile + Vector2i(1, 0),  # East
			current_tile + Vector2i(0, 1),  # South
			current_tile + Vector2i(-1, 0)  # West
		]

		for neighbor in neighbors:
			# Check bounds
			if neighbor.x < 0 or neighbor.x >= Global.MAP_SIZE.x:
				continue
			if neighbor.y < 0 or neighbor.y >= Global.MAP_SIZE.y:
				continue

			# Check if the neighbor tile is occupied by any unit
			if units.get_unit_at_tile(neighbor) != null:
				continue

			# Add neighbor to queue with incremented distance
			queue.append([neighbor, current_distance + 1])

	movable_tiles.append(start_tile)
	# Search for attackable tiles around movable tiles
	for movable_tile in movable_tiles:
		# Check neighboring tiles (N, E, S, W) for attackable range
		var neighbors = [
			movable_tile + Vector2i(0, -1),  # North
			movable_tile + Vector2i(1, 0),  # East
			movable_tile + Vector2i(0, 1),  # South
			movable_tile + Vector2i(-1, 0)  # West
		]

		for neighbor in neighbors:
			# Check bounds
			if neighbor.x < 0 or neighbor.x >= Global.MAP_SIZE.x:
				continue
			if neighbor.y < 0 or neighbor.y >= Global.MAP_SIZE.y:
				continue

			# Add to attackable_tiles if a unit is present
			var neighbor_unit = units.get_unit_at_tile(neighbor)
			if neighbor_unit != null:
				if neighbor_unit.parent_node == unit.parent_node:  # Exclude allies
					continue
				if neighbor not in attackable_tiles and neighbor != start_tile:
					attackable_tiles.append(neighbor)

	show_move_attack_tiles()


func show_move_attack_tiles():
	for tile in movable_tiles:
		if tile == selected_unit.current_tile:
			continue
		var sprite = Sprite2D.new()
		sprite.texture = movable_texture
		sprite.position = tile * Global.TILE_SIZE
		add_child(sprite)
		movable_tiles_sprites.append(sprite)
	for tile in attackable_tiles:
		var sprite = Sprite2D.new()
		sprite.texture = attackable_texture
		sprite.position = tile * Global.TILE_SIZE
		add_child(sprite)
		attackable_tiles_sprites.append(sprite)

func clear_move_attack_tiles():
	print("Clearing move and attack tiles")
	for tile in movable_tiles_sprites:
		tile.queue_free()
	movable_tiles_sprites = []
	for tile in attackable_tiles_sprites:
		tile.queue_free()
	attackable_tiles_sprites = []
	movable_tiles = []
	attackable_tiles = []

func check_if_movable(tile_position: Vector2) -> bool:
	for t in movable_tiles:
		if t.x == tile_position.x and t.y == tile_position.y:
			return true
	return false

func check_if_attackable(tile: Dictionary) -> bool:
	for t in attackable_tiles:
		if t.x == tile["position"].x and t.y == tile["position"].y:
			if check_if_movable(Vector2(t.x, t.y) + tile["side"]):
				return true
	return false

func _start_player_turn(unit: Unit):
	active = true
	selected_unit = unit
	print("Player turn started for unit at tile: ", unit.current_tile)
	select_character(unit.current_tile)
	search_move_attack_range(unit)

func _deactivate():
	active = false
	delete_highlight()
	delete_selection()

func connect_signals():
	units.player_turn_started.connect(_start_player_turn)
