extends Node

# 9 cells
const mooreNeighbors = [
	Vector2(-1 , 1), Vector2(0 , 1),  Vector2(1 , 1),
	Vector2(-1 , 0),  Vector2(0, 0),  Vector2(1 , 1), 
	Vector2(-1 , -1), Vector2(0 , -1), Vector2(1 , -1)
]

# 5 cells, Moore without corners
const vonNeumannNeighbors = [
	Vector2(0 , 1),
	Vector2(-1 , 0),  Vector2(0, 0),  Vector2(1 , 1),
	Vector2(0 , -1),
]

# Constructs a new internal tile object matching the tile in tileMap at the given position
# Param: tileMap - the worldMap to get tile information from
# Param: nameMap - an array matching names of tiles in the TileSet to TileSet IDs
func getInternalTile(tileMap, pos, nameMap):
	var id = tileMap.get_cellv(pos)
	var name = nameMap[id] if id != -1 else ""
	# assert(id != -1, "someone should really make sure that the map has no holes in it")
	var tile = Internal_Tile.new(name)
	tile.pos = pos
	return tile

#makes an array of tile names, where the index is the tileSet Id
func generateTileIDMap(tileMap):
	var tileIDArray = tileMap.tile_set.get_tiles_ids()
	var tileNameMap = []
	for id in tileIDArray:
		tileNameMap.append(tileMap.tile_set.tile_get_name(id))
	return tileNameMap

# Manhattan distance from posA to posB
func manhattanDistance(posA : Vector2, posB : Vector2) -> int:
	return int(abs(posB.x - posA.x) + abs(posB.y - posA.y))

#looks through internal tiles for rightmost column that has full fire level
func findForwardMostFullFireColumn(tiles):
	var mostForwardColumn = -1


	for x in range(len(tiles[0]) - 1, -1, -1):
		var full = true
		for y in len(tiles):
			if tiles[y][x].fireLevel != Internal_Tile.maxFireLevel:
				full = false
				break
		if full:
			mostForwardColumn = x
			break
	return mostForwardColumn

func randInt(to:int, from:int) -> int:
	assert(from - to > 0)
	return (randi()%(from + 1 - to)) + to
