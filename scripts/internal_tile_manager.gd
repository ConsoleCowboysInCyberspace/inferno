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
var cellSize = 64
var windTimer
var scoreTimer
var mostForwardCol = -1
var numTowns = 0
var score = 0
signal windFireStarted(pos)

const fireSpreadStrength = .8 #constant multiplier for burn size
const fireSpreadTime = 1.5 #timeInSeconds
const fireGrowthMultiplier = .1
var timeUntilNextFireSpread = fireSpreadTime

# Returns the tile object at the given grid position
func getTile(pos: Vector2):
	assert(tileInBounds(pos), "Tile out of bounds")
	return tiles[pos.y][pos.x]

func setTile(pos: Vector2, type):
	tiles[pos.y][pos.x] = Internal_Tile.new(type)
	worldMap.set_cellv(pos, worldTileSetNameMap.find(type))

func burnTile(pos: Vector2, type):
	var xFlip = worldMap.is_cell_x_flipped(pos.x, pos.y)
	var yFlip = worldMap.is_cell_y_flipped(pos.x, pos.y)
	var transposed = worldMap.is_cell_transposed(pos.x, pos.y)
	var newType = worldMap.get_cellv(pos)
	
	match type:
		Internal_Tile.TileType.FOREST:
			newType = worldTileSetNameMap.find("burnedForest")
		Internal_Tile.TileType.FOREST_DRY:
			newType = worldTileSetNameMap.find("burnedForest")
		Internal_Tile.TileType.TOWN:
			newType = worldTileSetNameMap.find("townBurned")
		Internal_Tile.TileType.TOWN_SMALL:
			newType = worldTileSetNameMap.find("townBurnedSmall")
		Internal_Tile.TileType.GRASS:
			newType = worldTileSetNameMap.find("grassBurned")
		Internal_Tile.TileType.ROAD:
			newType = worldTileSetNameMap.find("roadBurned")
		Internal_Tile.TileType.ROAD_CROSS:
			newType = worldTileSetNameMap.find("roadCrossBurned")
		Internal_Tile.TileType.ROAD_TURN:
			newType = worldTileSetNameMap.find("roadTurnBurned")
		Internal_Tile.TileType.ROAD_T:
			newType = worldTileSetNameMap.find("roadTBurned")
		Internal_Tile.TileType.ROAD_END:
			newType = worldTileSetNameMap.find("roadEndBurned")
	
	worldMap.set_cellv(pos, newType, xFlip, yFlip, transposed)

func setTileSprite(pos, type):
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
			if(tile.type == Internal_Tile.TileType.TOWN):
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
	windTimer.process_mode = 0
	windTimer.wait_time = Utils.randInt(15, 20)
	windTimer.set_one_shot(false)
	windTimer.start()
	
	scoreTimer = Timer.new()
	scoreTimer.connect("timeout", self, "incScore")
	add_child(scoreTimer)
	scoreTimer.wait_time = 5
	scoreTimer.set_one_shot(false)
	scoreTimer.start()
	
	print("score timer ", scoreTimer)

func incScore():
	score += numTowns
	
	print("Score = ", score)
	
func lose():
	pass
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
			getTile(Vector2(x,y)).burnSelf(fireGrowthMultiplier)
			
			
func setBurnLevel(burnLevelsArr, pos):
	var fireLevel = getTile(pos).fireLevel
	var neighbors = [] 
	# if getTile(pos).burnedDown:
	# 	return
	for potentialNeighbor in Utils.mooreNeighbors:
		if tileInBounds(pos + potentialNeighbor) && getTile(pos + potentialNeighbor).nonFlammable == false and potentialNeighbor != Vector2.ZERO:
			neighbors.append(pos + potentialNeighbor)
	
	var tileToBurn = neighbors[rand_range(0, len(neighbors))]
	burnLevelsArr[tileToBurn.y][tileToBurn.x] += fireSpreadStrength * sqrt(fireLevel)

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
		lose()

func windTimerTimeout():
	mostForwardCol = Utils.findForwardMostFullFireColumn(tiles)
	if mostForwardCol == -1:
		print("not enough fire")
		windTimer.start()
		return

	windTimer.stop()
	windTimer.disconnect("timeout", self, "windTimerTimeout")
	windTimer.connect("timeout", self, "startWindFire")
	windTimer.wait_time = 7
	windTimer.one_shot = true

	#todo move wind
	windEmbers.position.x = tileToWorld(Vector2(mostForwardCol, 0)).x
	windEmbers.emitting = true
	windTimer.start()


func startWindFire():
	var newFires = Utils.randInt(1, 2)
	var forwardDistance = Utils.randInt(10, 18) # Range of distance from mostForwardCol that fire can spawn
	var fireTiles = []
	for i in range(newFires):
		fireTiles.append(Vector2(mostForwardCol + forwardDistance + Utils.randInt(0, 5), Utils.randInt(5, len(tiles) - 5)))
	for pos in fireTiles:
		if(tileInBounds(pos)):
			tiles[pos.y][pos.x].fireLevel = Internal_Tile.maxFireLevel / 10
			emit_signal("windFireStarted", pos)

	windTimer.disconnect("timeout", self, "startWindFire")
	windTimer.connect("timeout", self, "endWindFire")
	windTimer.wait_time = 1
	windTimer.one_shot = true
	windTimer.start()

func endWindFire():
	windEmbers.emitting = false
	windTimer.disconnect("timeout", self, "endWindFire")
	windTimer.connect("timeout", self, "windTimerTimeout")
	windTimer.wait_time = Utils.randInt(25, 36)
	windTimer.one_shot = false
	windTimer.start()

func nukeItFromOrbit():
	for y in range(size.y):
		for x in range(size.x):
			if fireTiles[y][x]:
				fireTiles[y][x].free()
			fireTiles[y][x] = null
			tiles[y][x].free()
			tiles[y][x] = null
	tiles.resize(0)
	fireTiles.resize(0)
	size = Vector2(0,0)
