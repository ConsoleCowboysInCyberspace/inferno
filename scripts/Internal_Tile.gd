extends Object
class_name Internal_Tile

enum TileType {EMPTY, TOWN, FOREST, WATER, ROAD, TRENCH, DRYFOREST,MOUNTAIN, GRASS, BLANK}
const maxFireLevel = 400

var pos: Vector2
var fireLevel: int = 0
var fireResistance: int
var movementCost: int = 1
var type
var nonFlammable = false
var neighbors = []
var lowParticle = false
var burnedDown = false

func _init(tileType):
	fireLevel = 0
	
	match tileType:
		"":
			fireResistance = 0
			movementCost = -1
			type = TileType.EMPTY
			nonFlammable = true
		"blank":
			fireResistance = 0
			movementCost = -1
			type = TileType.BLANK
			nonFlammable = true
		"forest":
			fireResistance = 2
			movementCost = 2
			type = TileType.FOREST
		"forestDry":
			fireResistance = 0
			movementCost = 2
			type = TileType.FOREST
		"town":
			fireResistance = 2
			movementCost = -1
			type = TileType.TOWN
		"townSmall":
			fireResistance = 2
			movementCost = -1
			type = TileType.TOWN
		"water":
			fireResistance = 0
			movementCost = -1 # tiles with negative movementCost can't be traversed
			type = TileType.WATER
		"road":
			fireResistance = 5
			movementCost = 1
			type = TileType.ROAD
		"trench":
			fireResistance = 15
			movementCost = 2
			type = TileType.TRENCH
		"mountain":
			fireResistance = 0
			movementCost = -1
			type = TileType.MOUNTAIN
			nonFlammable = true
		"grass":
			fireResistance = 4
			movementCost = 2
			type = TileType.GRASS
		_:
			assert(0, "you have fucked up, " + str(tileType))



	
func water():
	#fireLevel = clamp(fireLevel - 50, 0, maxFireLevel)
	fireLevel = 0

func burnDown():
	fireResistance = 0
	tile_manager.burnTile(pos, type)
	if type == TileType.TOWN:
		pass
		

func burn(burnLevel):
	if fireResistance == -1 || nonFlammable:
		return
	fireLevel += clamp(clamp(burnLevel - fireResistance, 0, 100), 0, 100)

	if fireLevel > maxFireLevel/2 && !burnedDown:
		burnDown()
	

