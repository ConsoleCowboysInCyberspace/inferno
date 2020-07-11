extends Node2D

const maxVelocity = 100

export var squareSize : int
var movingDir = Vector2.ZERO # Unit vector
var velocity = 0
var tilePos = Vector2.ZERO # Position of the truck in tile grid coordinates
var targetPos = null

# Custom init that is called from the controller
func customInit():
	position = tile_manager.tileToWorld(tile_manager.worldToTile(position))
	tilePos = tile_manager.worldToTile(position)
# func _input(event):
# 	if event.is_action_pressed("fire_hose"):
# 		var target = controller.worldToTile(event.position)


func _process(delta):
	if Input.is_action_just_released("dig_trench"):
		#digTrench()
		pass
	
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
			prints("Can't move there", tilePos + movingDir)
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
			print("Mouse Click at: ", event.position, "    Tile coords: ", tile_manager.worldToTile(event.position))

# Checks if we can dig a trench at the given position in the tile grid
# If we can, change the tile to a trench
func digTrench():
	if tile_manager.getTile(tilePos) == Internal_Tile.TileType.FOREST:
		tile_manager.setTile(tilePos, "trench")

