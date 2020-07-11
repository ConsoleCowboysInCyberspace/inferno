extends Node2D

const maxVelocity = 100
const max_water = 100 # 100 for easy integration with UI
const water_per_firing = 25 #noice and round
export var water_amount = max_water
signal water_changed(water_amount)

export var squareSize : int
var movingDir = Vector2.ZERO # Unit vector
var velocity = 0
var tilePos = Vector2.ZERO # Position of the truck in tile grid coordinates
var targetPos = null
var digTimer = Timer

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

func _process(delta):
	if Input.is_action_just_released("dig_trench"):
		digTrench()
	
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
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT && event.pressed:
			on_left_clicked(event)


func on_left_clicked(event : InputEvent):
	# redundant calls
	print("Mouse Click at: ", event.position, "    Tile coords: ", tile_manager.worldToTile(event.position))

	var pos = event.position
	var tile_coord = tile_manager.worldToTile(pos)

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
# If we can, change the tile to a trench
func digTrench():
	if tile_manager.getTile(tilePos).type == Internal_Tile.TileType.FOREST:
		tile_manager.setTile(tilePos, "trench")

