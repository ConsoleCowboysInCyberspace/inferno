extends Node
class_name Internal_Tile

enum TileType {TOWN, FOREST, WATER, ROAD, TRENCH}

var pos: Vector2
var fireLevel: int = 0
var fireResistance: int
var movementCost: int
var type: TileType
var nonFlamable = False

func _init(type):
	fireLevel = 0
	match type:
		"forest":
			fireResistance = 0
			movementCost = 2
			type = FOREST
		"town":
			fireResistance = 0
			movementCost = 1
			type = TOWN
		"water":
			fireResistance = 0
			movementCost = -1 # tiles with negative movementCost can't be traversed
			type = WATER
		"road":
			fireResistance = 0
			movementCost = 1
			type = ROAD
		"trench":
			fireResistance = 0
			movementCost = 2
			type = TRENCH
			



