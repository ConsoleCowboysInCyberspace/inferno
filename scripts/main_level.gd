extends Node2D

var cellSize = 32
export var size: Vector2 = Vector2(50, 50) #The size of the game grid
var tiles: Array = [] # 2d array, [y][x]
onready var worldMap: TileMap = get_node("worldMap") #TileMap node which we are using to render
onready var fireMap: TileMap = get_node("fireMap") #TileMap of the fire that will be drawn over the world
onready var truck = get_node("Fire Truck")
var fireSpreadTime = 1 #timeInSeconds

# Returns -1 for non-traversable tiles and out of bounds positions
# Otherwise, returns the movementCost of the tile at the given position
# Param: pos - Vector2 - a position on the tile grid to be checked
func tileMoveCost(pos):
	if tileInbounds(pos): # are we out of the grid?
		return -1
	else:
		return tiles[pos.y][pos.x].movementCost


func tileInbounds(tilePos):
	return worldMap.get_cellv(tilePos) != TileMap.INVALID_CELL

# Returns the position of the tile in the grid that contains the given coordinates
# Param: tilePos - Vector2
# Return: Vector2
func tileToWorld(tilePos):
	var retCoord = worldMap.map_to_world(tilePos)
	retCoord.x +=cellSize/2
	retCoord.y +=cellSize/2
	return retCoord

# Returns the coordinates of the center of the tile at the given position
# Param: worldPos - Vector2
# Return: Vector2
func worldToTile(worldPos):
	return worldMap.world_to_map(worldPos)

# Constructs a new internal tile object matching the tile in gridMap at the given position
func getInternalTile(tileMap, pos, nameMap):
	var id = tileMap.get_cellv(pos)
	assert(id != -1, "someone should really make sure that the map has no holes in it")
	var tile = Internal_Tile.new(nameMap[id])
	tile.pos = pos
	return tile
			
func generateTileIDMap(tileMap):
	var tileIDArray = tileMap.tile_set.get_tiles_ids()
	var tileNameMap = []
	for id in tileIDArray:
		tileNameMap.append(tileMap.tile_set.tile_get_name(id))
	return tileNameMap

# Called when the node enters the scene tree for the first time.
func _ready():
	var worldTileSetNameMap = generateTileIDMap(worldMap)

	for y in range(size.y):
		var row = []
		for x in range(size.x):
			var pos = Vector2(x,y)
			var tile = getInternalTile(worldMap, pos, worldTileSetNameMap)
			if fireMap.get_cellv(pos) != -1:
				tile.fireLevel = 100 #todo set this to max
			row.append(tile)
		tiles.append(row)
	truck.customInit()

func fireSpread():
	
	var nextFireLevelsArr = [] #2d arr
	for y in range(size.y):
		var row = []
		for x in range(size.x):
			var fireStats = [tiles[y][x].fireLevel, tiles[y][x].fireResistance]
			row.append(fireStats)
			nextFireLevelsArr.append(row)
	
	for y in range(size.y):
		for x in range(size.x):
			

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

#func _physics_process(delta):
#	pass
