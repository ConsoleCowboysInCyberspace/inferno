extends Object
class_name Internal_Tile

enum TileType {TOWN, FOREST, WATER, ROAD, TRENCH}
const maxFireLevel = 100

var pos: Vector2
var fireLevel: int = 0
var fireResistance: int
var movementCost: int
var type
var nonFlamable = false
var neighbors = []

func _init(tileType):
	fireLevel = 0
	
	match tileType:
		"forest":
			fireResistance = 5
			movementCost = 2
			type = TileType.FOREST
		"town":
			fireResistance = 5
			movementCost = 1
			type = TileType.TOWN
		"water":
			fireResistance = 5
			movementCost = -1 # tiles with negative movementCost can't be traversed
			type = TileType.WATER
		"road":
			fireResistance = 5
			movementCost = 1
			type = TileType.ROAD
		"trench":
			fireResistance = 5
			movementCost = 2
			type = TileType.TRENCH
			
func burn(burnLevel):
	if fireResistance > burnLevel or fireLevel == maxFireLevel:
		return
	
	else:
		fireLevel += burnLevel - fireResistance
		if fireLevel > maxFireLevel:
			fireLevel = maxFireLevel


