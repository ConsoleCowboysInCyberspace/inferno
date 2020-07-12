extends Object
class_name Internal_Tile

enum TileType {EMPTY, TOWN, FOREST, WATER, ROAD, TRENCH, DRYFOREST}
const maxFireLevel = 400

var pos: Vector2
var fireLevel: int = 0
var fireResistance: int
var movementCost: int
var type
var nonFlamable = false
var neighbors = []
var lowParticle = false

func _init(tileType):
	fireLevel = 0
	
	match tileType:
		"":
			fireResistance = 0
			movementCost = -1
			type = TileType.EMPTY
			nonFlamable = true
		"forest":
			fireResistance = 2
			movementCost = 2
			type = TileType.FOREST
		"dryForest":
			fireResistance = 0
			movementCost = 2
			type = TileType.FOREST
		"town":
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
	
func water():
	fireLevel = clamp(fireLevel - 50, 0, maxFireLevel)

func burnDown():
	fireResistance = 0
	if tile.type == TileType.TOWN:
		internalTile.burnTown()

func burn(burnLevel):
	if fireResistance == -1 || nonFlamable:
		return
	fireLevel += clamp(clamp(burnLevel - fireResistance, 0, 100), 0, 100)
	if(firelevel > maxFireLevel/2):
		burnDown()
	

