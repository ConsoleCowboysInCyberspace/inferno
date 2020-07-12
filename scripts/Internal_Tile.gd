extends Object
class_name Internal_Tile

enum TileType {EMPTY, TOWN, TOWN_SMALL, FOREST, FOREST_DRY, WATER, ROAD, ROAD_T, ROAD_END, ROAD_TURN, ROAD_CROSS, TRENCH, DRYFOREST,MOUNTAIN, GRASS, BLANK}
const maxFireLevel = 400
const roadFireResist = 8

var pos: Vector2
var fireLevel: int = 0
var fireResistance: int
var movementCost: float  = 1
var type
var nonFlammable = false
var neighbors = []
var lowParticle = false
var burnedDown = false
var diggable = false

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
			movementCost = 1
			type = TileType.BLANK
			nonFlammable = true
		"forest":
			fireResistance = 4
			movementCost = 2
			type = TileType.FOREST
			diggable = true
		"forestDry":
			fireResistance = 0
			movementCost = 2
			type = TileType.FOREST_DRY
			diggable = true
		"town":
			fireResistance = 4
			movementCost = -1
			type = TileType.TOWN

		"townSmall":
			fireResistance = 4
			movementCost = -1
			type = TileType.TOWN_SMALL
		"water":
			fireResistance = 0
			movementCost = -1 # tiles with negative movementCost can't be traversed
			type = TileType.WATER
		"road":
			fireResistance = roadFireResist
			movementCost = 1
			type = TileType.ROAD
		"roadCross":
			fireResistance = roadFireResist
			movementCost = 1
			type = TileType.ROAD_CROSS
		"roadEnd":
			fireResistance = roadFireResist
			movementCost = 1
			type = TileType.ROAD_END
		"roadT":
			fireResistance = roadFireResist
			movementCost = 1
			type = TileType.ROAD_T
		"roadTurn":
			fireResistance = roadFireResist
			movementCost = 1
			type = TileType.ROAD_TURN
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
			fireResistance = 6
			movementCost = 1.5
			type = TileType.GRASS
			diggable = true
		_:
			assert(0, "you have fucked up, " + str(tileType))



	
func water():
	#fireLevel = clamp(fireLevel - 50, 0, maxFireLevel)
	fireLevel = 0

func burnDown():
	fireResistance = 0
	burnedDown = true
	tile_manager.burnTile(pos, type)
	if type == TileType.TOWN || type == TileType.TOWN_SMALL:
		tile_manager.burnTown()
		

func burn(burnLevel):
	if fireResistance == -1 || nonFlammable:
		return
	fireLevel += clamp(clamp(burnLevel - fireResistance, 0, 100), 0, 100)

	if fireLevel > maxFireLevel/2 && !burnedDown:
		burnDown()
	

