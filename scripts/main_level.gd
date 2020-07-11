extends Node2D

export var size: Vector2 = Vector2(50, 50) #The size of the game grid
var tiles: Array = []
onready var worldMap: TileMap = get_node("WorldMap") #TileMap node which we are using to render
onready var fireMap: TileMap = get_node("FireMap") #TileMap of the fire that will be drawn over the world

# Returns an internal tile object matching the tile in gridMap at the given position
func getInternalTile(tileMap, pos):
	var id = tileMap.get_cellv(pos)
	var name = tileMap.tile_set.tile_get_name(id)
	var tile = Internal_Tile.new(name)
	tile.pos = pos
	return tile
			
# Called when the node enters the scene tree for the first time.
func _ready():
	for y in range(size.y):
		var row = []
		for x in range(size.x):
			pos = Vector2(x,y)
			tile = getInternalTile(worldMap, pos)
			if worldMap.get_cellv(pos) != -1:
				tile.fireLevel
			row.append(tile)
		tiles.append(row)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

#func _physics_process(delta):
#	pass
