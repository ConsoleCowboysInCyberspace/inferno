extends Node

var worldMap : TileMap
var fireMap : TileMap
var truck
var levelRoot
var worldTileSetNameMap
var tiles: Array = []
var fireTiles: Array = []
var size: Vector2
var fireParticleScene = preload("res://Scenes/Fire.tscn")
var cellSize: Vector2

var fireSpreadTime = 1 #timeInSeconds
var timeUntilNextFireSpread = fireSpreadTime
var neighborVectors = [
	Vector2(-1 , 1), Vector2(0 , 1),  Vector2(1 , 1),
	Vector2(-1 , 0),  Vector2(0, 0),  Vector2(1 , 1), 
	Vector2(-1 , -1), Vector2(0 , 1), Vector2(1 , -1)
]

func getTile(pos: Vector2):
	return tiles[pos.y][pos.x]

func setTile(pos: Vector2, type):
	tiles[pos.y][pos.x] = Internal_Tile.new(type)
	worldMap.set_cellv(pos, worldTileSetNameMap)

# Returns -1 for non-traversable tiles and out of bounds positions
# Otherwise, returns the movementCost of the tile at the given position
# Param: pos - Vector2 - a position on the tile grid to be checked
func tileMoveCost(pos):
	if !tileInBounds(pos): # are we out of the grid?
		return -1
	else:
		return tiles[pos.y][pos.x].movementCost

func tileInBounds(tilePos):
	return worldMap.get_cellv(tilePos) != TileMap.INVALID_CELL

# Returns the position of the tile in the grid that contains the given coordinates
# Param: tilePos - Vector2
# Return: Vector2
func tileToWorld(tilePos):
	var cellSize = 32
	var retCoord = worldMap.map_to_world(tilePos)
	retCoord.x +=cellSize/2
	retCoord.y +=cellSize/2
	return retCoord

# Returns the coordinates of the center of the tile at the given position
# Param: worldPos - Vector2
# Return: Vector2
func worldToTile(worldPos):
	return worldMap.world_to_map(worldPos)

# Constructs a new internal tile object matching the tile in tileMap at the given position
# Param: tileMap - the worldMap to get tile information from
# Param: nameMap - an array matching names of tiles in the TileSet to TileSet IDs
func getInternalTile(tileMap, pos, nameMap):
	var id = tileMap.get_cellv(pos)
	assert(id != -1, "someone should really make sure that the map has no holes in it")
	var tile = Internal_Tile.new(nameMap[id])
	tile.pos = pos
	return tile

#makes an array of tile names, where the index is the tileSet Id
func generateTileIDMap(tileMap):
	var tileIDArray = tileMap.tile_set.get_tiles_ids()
	var tileNameMap = []
	for id in tileIDArray:
		tileNameMap.append(tileMap.tile_set.tile_get_name(id))
	return tileNameMap

func makeNewFireInstance(pos):
	var newFire = fireParticleScene.instance()
	newFire.set_name("fire" + str(pos.x) + ", " + str(pos.y))
	levelRoot.add_child(newFire)
	newFire.position = tileToWorld(pos)
	return newFire

func customInit():
	worldTileSetNameMap = generateTileIDMap(worldMap)
	fireMap.visible = false

	for y in range(size.y):
		var row = []
		var fireRow = []
		for x in range(size.x):
			var pos = Vector2(x,y)
			var tile = getInternalTile(worldMap, pos, worldTileSetNameMap)
			var fire = null
			if fireMap.get_cellv(pos) != -1:
				tile.fireLevel = 100 #todo set this to max
				fire = makeNewFireInstance(pos)
			row.append(tile)
			fireRow.append(fire)
		tiles.append(row)
		fireTiles.append(fireRow)
	truck.customInit()

func fireSpread():
	var burnLevelsArr = [] #2d arr
	for y in range(size.y):
		var row = []
		for x in range(size.x):
			var fireStats = tiles[y][x].fireLevel
			row.append(fireStats)
			burnLevelsArr.append(row)
	
	for y in range(size.y):
		for x in range(size.x):
			fireSpreadHelperSchemeOne(burnLevelsArr, Vector2(x, y))

	for y in range(size.y):
		for x in range(size.x):
			tiles[y][x].burn(burnLevelsArr[y][x])
			
			
func fireSpreadHelperSchemeOne(burnLevelsArr, pos):
	var fireLevel = tiles[pos.y][pos.x].fireLevel
	var neighbors = [] 

	for potentialNeighbor in neighborVectors:
		if tileInBounds(pos + potentialNeighbor):
			neighbors.append(pos + potentialNeighbor)
	
	var tileToBurn = neighbors[rand_range(0, len(neighbors))]
	burnLevelsArr[tileToBurn.y][tileToBurn.x] += fireLevel/10

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
				fireTiles[y][x].get_process_material().scale = (tile.fireLevel/float(Internal_Tile.maxFireLevel)) * 2
