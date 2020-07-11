extends Node

var worldMap : TileMap
var worldTileSetNameMap
var tiles: Array = []
var truck

func getTile(pos: Vector2):
	return tiles[pos.y][pos.x]

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

func init(tiles, size):
	worldTileSetNameMap = generateTileIDMap(worldMap)
	
	#for y in range(size.y):
	#	var row = []
	#	for x in range(size.x):
	#		var pos = Vector2(x,y)
	#		var tile = getInternalTile(worldMap, pos, worldTileSetNameMap)
	#		if fireMap.get_cellv(pos) != -1:
	#			tile.fireLevel = 100 #todo set this to max
	#		row.append(tile)
	#	tiles.append(row)
	#truck.customInit()

func _ready():
	pass # Replace with function body.
