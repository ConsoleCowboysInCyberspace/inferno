extends Node

var worldMap : TileMap
var fireMap : TileMap
var truck
var levelRoot
var windEmbers
var worldTileSetNameMap
var tiles: Array = []
var fireTiles: Array = []
var size: Vector2
const fireParticleScene = preload("res://Scenes/Fire.tscn")
const fireLowParticleScene = preload("res://Scenes/FireLow.tscn")
var cellSize
var windTimer
var mostForwardCol = -1
var numTowns = 0
var score = 0

const fireSpreadStrength = 2 #constant multiplier for burn size
const fireSpreadTime = 1 #timeInSeconds
var timeUntilNextFireSpread = fireSpreadTime

# Returns the tile object at the given grid position
func getTile(pos: Vector2):
	assert(tileInBounds(pos), "Tile out of bounds")
	return tiles[pos.y][pos.x]

func setTile(pos: Vector2, type):
	tiles[pos.y][pos.x] = Internal_Tile.new(type)
	worldMap.set_cellv(pos, worldTileSetNameMap.find(type))

# Returns -1 for non-traversable tiles and out of bounds positions
# Otherwise, returns the movementCost of the tile at the given position
# Param: pos - a position on the tile grid to be checked
func tileMoveCost(pos: Vector2):
	if !tileInBounds(pos): # are we out of the grid?
		return -1
	else:
		return tiles[pos.y][pos.x].movementCost

func tileInBounds(tilePos):
	return worldMap.get_used_rect().has_point(tilePos)

# Returns the position of the tile in the grid that contains the given coordinates
func tileToWorld(tilePos: Vector2) -> Vector2 :
	var retCoord = worldMap.map_to_world(tilePos)
	retCoord.x +=cellSize/2
	retCoord.y +=cellSize/2
	return retCoord

# Returns the coordinates of the center of the tile at the given position
func worldToTile(worldPos : Vector2) -> Vector2 :
	return worldMap.world_to_map(worldPos)

func makeNewFireInstance(pos):
	var newFire = fireParticleScene.instance()
	newFire.set_name("fire" + str(pos.x) + ", " + str(pos.y))
	levelRoot.add_child(newFire)
	newFire.position = tileToWorld(pos)
	return newFire

func makeNewLowFireInstance(pos):
	var newFire = fireLowParticleScene.instance()
	newFire.set_name("fireLow" + str(pos.x) + ", " + str(pos.y))
	levelRoot.add_child(newFire)
	newFire.position = tileToWorld(pos)
	return newFire

func customInit():
	worldTileSetNameMap = Utils.generateTileIDMap(worldMap)
	if fireMap != null:
		fireMap.visible = false

	for y in range(size.y):
		var row = []
		var fireRow = []
		for x in range(size.x):
			var pos = Vector2(x,y)
			var tile = Utils.getInternalTile(worldMap, pos, worldTileSetNameMap)
			var fire = null
			if fireMap != null && fireMap.get_cellv(pos) != -1:
				tile.fireLevel = Internal_Tile.maxFireLevel #todo set this to max
				fire = makeNewFireInstance(pos)
			if(tile.name == "Town"):
				numTowns += 1
			row.append(tile)
			fireRow.append(fire)
		tiles.append(row)
		fireTiles.append(fireRow)
	
	if truck != null:
		truck.customInit()
	
	windTimer = Timer.new()
	windTimer.connect("timeout", self, "windTimerTimeout")
	add_child(windTimer)
	windTimer.wait_time = Utils.randInt(10, 15)
	windTimer.set_one_shot(false)
	windTimer.start()

func fireSpread():
	var burnLevelsArr = [] #2d arr
	
	# populate burnLevelsArr
	for y in range(size.y):
		var row = []
		for x in range(size.x):
			row.append(0)
		burnLevelsArr.append(row)
	
	# simulate burning -- may affect several tiles concurrently
	for y in range(size.y):
		for x in range(size.x):
			setBurnLevel(burnLevelsArr, Vector2(x, y))
			
	# write back updated burning values
	for y in range(size.y):
		for x in range(size.x):
			#print("burned tile " + str(x) + ", " + str(y) + "for value " + str(burnLevelsArr[y][x]))
			getTile(Vector2(x,y)).burn(burnLevelsArr[y][x])
			
			
func setBurnLevel(burnLevelsArr, pos):
	var fireLevel = getTile(pos).fireLevel
	var neighbors = [] 

	for potentialNeighbor in Utils.mooreNeighbors:
		if tileInBounds(pos + potentialNeighbor):
			neighbors.append(pos + potentialNeighbor)
	
	var tileToBurn = neighbors[rand_range(0, len(neighbors))]
	burnLevelsArr[tileToBurn.y][tileToBurn.x] += fireSpreadStrength * log(fireLevel)

func _physics_process(delta):
	if timeUntilNextFireSpread <= 0:
		fireSpread()
		timeUntilNextFireSpread = fireSpreadTime
	else:
		timeUntilNextFireSpread -= delta

func _process(delta):
	for y in range(size.y):
		for x in range(size.x):
			var tile = tiles[y][x]
			if tile.fireLevel > 0:
				if !fireTiles[y][x]:
					fireTiles[y][x] = makeNewFireInstance(Vector2(x,y))
				var scale = clamp((tile.fireLevel/float(Internal_Tile.maxFireLevel)) * 1.5, 0.5, 1.5 )
				fireTiles[y][x].scale = Vector2(scale, scale)
			else:
				if fireTiles[y][x]:
					fireTiles[y][x].free()
					fireTiles[y][x] = null

func burnTown():
	numTowns -= 1
	if (numTowns <= 0):
		print("haha fuckin loser git gud")

func windTimerTimeout():
	mostForwardCol = Utils.findForwardMostFullFireColumn(tiles)
	if mostForwardCol == -1:
		windTimer.wait_time = Utils.randInt(30, 50)
		windTimer.start()
		return

	windTimer.stop()
	windTimer.disconnect("timeout", self, "windTimerTimeout")
	windTimer.connect("timeout", self, "startWindFire")
	windTimer.wait_time = 7
	windTimer.one_shot = true

	#todo move wind
	windEmbers.emitting = true
	windTimer.start()


func startWindFire():
	var newFires = Utils.randInt(1, 3)
	var forwardDistance = Utils.randInt(10, 18) # Range of distance from mostForwardCol that fire can spawn
	var fireTiles = []
	for i in range(newFires):
		fireTiles.append(Vector2(mostForwardCol + forwardDistance + Utils.randInt(0, 5), Utils.randInt(5, len(tiles) - 5)))
	for pos in fireTiles:
		tiles[pos.y][pos.x].fireLevel = Internal_Tile.maxFireLevel / 10

	windTimer.disconnect("timeout", self, "startWindFire")
	windTimer.connect("timeout", self, "endWindFire")
	windTimer.wait_time = 1
	windTimer.one_shot = true
	windTimer.start()

func endWindFire():
	windEmbers.emitting = false
	windTimer.disconnect("timeout", self, "endWindFire")
	windTimer.connect("timeout", self, "windTimerTimeout")
	windTimer.wait_time = Utils.randInt(30, 50)
	windTimer.one_shot = false
	windTimer.start()
