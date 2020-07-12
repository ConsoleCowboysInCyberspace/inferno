extends Node2D

const maxVelocity = 200
const max_water = 100 # 100 for easy integration with UI
const water_per_firing = 2 #noice and round
export var water_amount = max_water
export var water_fill_rate = 50 # amount of water restored over a second
export var waterCannonRange = 1

signal water_changed(water_amount)
var watering_timer : Timer

export var digTime : int
#export var squareSize : int
var movingDir = Vector2.ZERO # Unit vector
var velocity = 0
var tilePos = Vector2.ZERO # Position of the truck in tile grid coordinates
var targetPos = null
# var digTimer : Timer
var digPos : Vector2 = Vector2(-1, -1)
var digAmount: float = 0
signal digAmountChanged(digAmount)

var lastMousePosition: Vector2 = Vector2(0, 0)

onready var sprite = $Sprite

# Custom init that is called from the controller
func customInit():
	# song and dance to make sure we're always centered on a tile
	# (e.g. if we're dropped in willy-nilly from the editor)
	position = tile_manager.tileToWorld(tile_manager.worldToTile(position))
	tilePos = tile_manager.worldToTile(position)
	
	emit_signal("water_changed", water_amount) #initialize UI

func _ready():
	""" digTimer = Timer.new()
	digTimer.connect("timeout", self, "_on_digTimer_timeout")
	digTimer.one_shot = true
	add_child(digTimer) """

func setup_water(): #rreeeee
	watering_timer

var fireButtonPressed: bool = false
var digButtonPressed: bool = false
func _process(delta):
	if not digButtonPressed:
		digButtonPressed = Input.is_action_just_pressed("dig_trench")
	
	if Input.is_mouse_button_pressed(BUTTON_LEFT):
		lastMousePosition = get_global_mouse_position()
		fireButtonPressed = true
	
	if !targetPos:
		if Input.is_action_pressed("truck_up"):
				movingDir = Vector2.UP
				sprite.play("up")
		if Input.is_action_pressed("truck_down"):
				movingDir = Vector2.DOWN
				sprite.play("down")
		if Input.is_action_pressed("truck_left"):
				movingDir = Vector2.LEFT
				sprite.play("left")
		if Input.is_action_pressed("truck_right"):
				movingDir = Vector2.RIGHT
				sprite.play("right")
		
		if movingDir != Vector2.ZERO:
			# check move cost
			# this line is to make movement speed based on origin tile instead of destination tile
			var destination_cost = tile_manager.tileMoveCost(tilePos + movingDir)
			# the ternary is also there for the same reason; if we want to revert this, end the line before if and add a '+ movingDir' in the tileMoveCost
			var moveCost = tile_manager.tileMoveCost(tilePos) if destination_cost != -1 else -1
			
			if moveCost == -1:
				movingDir = Vector2.ZERO
			else:
				targetPos = tile_manager.tileToWorld(tilePos + movingDir)
				velocity = maxVelocity/moveCost

func _physics_process(delta):
	if fireButtonPressed:
		try_fire_cannon(delta, lastMousePosition)
	
	digTrench(delta)
	
	if targetPos:
		position = position.move_toward(targetPos, velocity * delta)
		if (position == targetPos):
			tilePos = tile_manager.worldToTile(position)
			movingDir = Vector2.ZERO
			targetPos = null
			velocity = 0

func try_fire_cannon(delta, mousePosition):
	# redundant calls
	#print("Trying to fire cannon at: ", mousePosition, "    Tile coords: ", tile_manager.worldToTile(mousePosition))

	var mousePosInTiles = tile_manager.worldToTile(mousePosition)

	# check if click is in bounds
	if (!tile_manager.tileInBounds(mousePosInTiles)):
		#print("tile not in bounds")
		return

	var tile = tile_manager.getTile(mousePosInTiles)
	var distToClick = Utils.manhattanDistance(tilePos, mousePosInTiles)

	# if tile is adjacent to truck and is a well
	if distToClick <= 1 && tile.type == Internal_Tile.TileType.WATER:
		fill_water(delta, tile)
	elif distToClick <= waterCannonRange:
		fireWaterCannon(delta, tile)
	else:
		return

# fires water on tile unless truck has ed
func fireWaterCannon(delta, tile):
	#print("firing water cannon at ", tile)
	#print(water_amount)
	#print(water_per_firing)
	var new_amount = water_amount - water_per_firing * delta
	
	if (new_amount < 0):
		# shoot dust, be sad UwU
		#print("truck has insufficient water")
		pass
	else:
		tile.water()
		water_amount = new_amount
		emit_signal("water_changed", water_amount)

func fill_water(delta, tile):
	#print("filling water")
	water_amount += water_fill_rate * delta
	emit_signal("water_changed", water_amount)
	# some animations, some animations on the tile maybe?

# Checks if we can dig a trench at the given position in the tile grid
# If we can, start digging
func digTrench(delta):
	if digPos == Vector2(-1, -1) and digButtonPressed:
		if tile_manager.getTile(tilePos).type == Internal_Tile.TileType.FOREST:
			digPos = tilePos
			digAmount = 0
			emit_signal("digAmountChanged", digAmount)
	elif digPos != tilePos || targetPos != null: # moving
		digPos = Vector2(-1, -1)
		digAmount = 0
		emit_signal("digAmountChanged", digAmount)
		digButtonPressed = false
		
		return
	else:
		digAmount += 75 * delta #75% dig/sec?
		
		if digAmount >= 100: #done
			tile_manager.setTile(tilePos, "trench")
			
			digPos = Vector2(-1, -1)
			digAmount = 100
			digButtonPressed = false
		
		emit_signal("digAmountChanged", digAmount)
