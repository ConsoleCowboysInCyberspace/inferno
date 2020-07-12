extends Node2D

const maxVelocity = 100
const max_water = 100 # 100 for easy integration with UI
const water_per_firing = 2 #noice and round
export var water_amount = max_water
signal water_changed(water_amount)
var is_watering = false
var watering_timer = Timer.new()

export var squareSize : int
var movingDir = Vector2.ZERO # Unit vector
var velocity = 0
var tilePos = Vector2.ZERO # Position of the truck in tile grid coordinates
var targetPos = null
var digTimer : Timer
var digPos : Vector2
var lastMousePosition: Vector2 = Vector2(0, 0)

# Custom init that is called from the controller
func customInit():
	# song and dance to make sure we're always centered on a tile
	# (e.g. if we're dropped in willy-nilly from the editor)
	position = tile_manager.tileToWorld(tile_manager.worldToTile(position))
	tilePos = tile_manager.worldToTile(position)
	
	emit_signal("water_changed", water_amount) #initialize UI

	# func _input(event):
# 	if event.is_action_pressed("fire_hose"):
# 		var target = controller.worldToTile(event.position)

func _ready():
	digTimer = Timer.new()
	digTimer.connect("timeout", self, "_on_digTimer_timeout")

func setup_water():
	watering_timer

func _process(delta):
	if Input.is_action_just_pressed("dig_trench"):
		digTrench()
	
	if Input.is_mouse_button_pressed(BUTTON_LEFT):
		try_fire_cannon(lastMousePosition)
	
	if !targetPos:
		if Input.is_action_pressed("truck_up"):
				movingDir = Vector2.UP
				$Sprite.play("up")
		if Input.is_action_pressed("truck_down"):
				movingDir = Vector2.DOWN
				$Sprite.play("down")
		if Input.is_action_pressed("truck_left"):
				movingDir = Vector2.LEFT
				$Sprite.play("left")
		if Input.is_action_pressed("truck_right"):
				movingDir = Vector2.RIGHT
				$Sprite.play("right")
		
		if movingDir != Vector2.ZERO:
			#check move cost
			# this line is to make movement speed based on origin tile instead of destination tile
			var destination_cost = tile_manager.tileMoveCost(tilePos + movingDir)
			# the ternary is also there for the same reason; if we want to revert this, end the line before if and add a '+ movingDir' in the tileMoveCost
			var moveCost = tile_manager.tileMoveCost(tilePos) if destination_cost != -1 else -1
			
			if moveCost == -1:
				print("Can't move there", tilePos + movingDir)
				movingDir = Vector2.ZERO
			else:
				targetPos = tile_manager.tileToWorld(tilePos + movingDir)
				velocity = 200/moveCost
			
	else:
		position = position.move_toward(targetPos, velocity * delta)
		if (position == targetPos):
			tilePos = tile_manager.worldToTile(position)
			movingDir = Vector2.ZERO
			targetPos = null
			velocity = 0

func _input(event):
	if event is InputEventMouseMotion:
		# we have to cache this as there is no way to proactively
		# query it from the Input system
		lastMousePosition = event.position

func try_fire_cannon(mousePosition):
	# redundant calls
	print("Trying to fire cannon at: ", mousePosition, "    Tile coords: ", tile_manager.worldToTile(mousePosition))

	var tile_coord = tile_manager.worldToTile(mousePosition)

	# check if click is in bounds
	if (!tile_manager.tileInBounds(tile_coord)):
		print("tile not in bounds")
		return

	var tile = tile_manager.getTile(tile_coord)

	# if tile is adjacent to truck
	if (Utils.manhattanDistance(tilePos, tile_coord)):
		
		# put out fire on tile
		fire_waterCannon(tile)

		# if water tile, fill water
		if (tile.type == Internal_Tile.TileType.WATER):
			fill_water(tile)
	
	else:
		print("click is further than 1 tile from truck")
		return

# fires water on tile unless truck has ed
func fire_waterCannon(tile):
	print("firing water cannon at ", tile)
	print(water_amount)
	print(water_per_firing)
	var new_amount = water_amount - water_per_firing
	
	if (new_amount < 0):
		# shoot dust, be sad UwU
		print("truck has insufficient water")
	else:
		tile.fireLevel -= 50 # make betterer
		water_amount = new_amount
		emit_signal("water_changed", water_amount)

func fill_water(tile):
	print("filling water")
	water_amount = max_water
	emit_signal("water_changed", water_amount)
	# some animations, some animations on the tile maybe?

# Checks if we can dig a trench at the given position in the tile grid
# If we can, start digging
func digTrench():
	if tile_manager.getTile(tilePos).type == Internal_Tile.TileType.FOREST:
		digPos = tilePos
		digTimer.start(1)

func _on_digTimer_timeout():
	if digPos == tilePos:
		tile_manager.setTile(tilePos, "trench")

