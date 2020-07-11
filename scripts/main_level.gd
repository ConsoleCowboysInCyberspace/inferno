extends Node2D

export var size: Vector2 = Vector2(10, 10) #The size of the game grid
onready var worldMap: TileMap = get_node("worldMap") #TileMap node which we are using to render
onready var fireMap: TileMap = get_node("fireMap") #TileMap of the fire that will be drawn over the world
onready var truck = get_node("Fire_Truck")

# Called when the node enters the scene tree for the first time.
func _ready():
	tile_manager.worldMap = worldMap
	tile_manager.fireMap = fireMap
	tile_manager.truck = truck
	tile_manager.levelRoot = self
	tile_manager.size = size
	tile_manager.cellSize = 32
	tile_manager.customInit()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
