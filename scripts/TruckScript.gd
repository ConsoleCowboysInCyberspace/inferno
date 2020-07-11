extends Node2D

const maxVelocity = 100

export var squareSize : int
var movingDir = Vector2.ZERO
var velocity = 0
var tilePos = Vector2.ZERO
var targetPos = null

onready var controller = get_parent()

# Custom init that is called from the controller
func customInit():
	position = controller.tileToWorld(controller.worldToTile(position))
	tilePos = controller.worldToTile(position)

# func _input(event):
# 	if event.is_action_pressed("fire_hose"):
# 		var target = controller.worldToTile(event.position)


func _process(delta):

	if !targetPos:
		if Input.is_action_pressed("truck_up"):
				movingDir = Vector2.UP
		if Input.is_action_pressed("truck_down"):
				movingDir = Vector2.DOWN
		if Input.is_action_pressed("truck_left"):
				movingDir = Vector2.LEFT
		if Input.is_action_pressed("truck_right"):
				movingDir = Vector2.RIGHT

		#check move cost
		var moveCost = controller.tileMoveCost(tilePos + movingDir)
		
		if moveCost == -1:
			print("Can't move there")
			movingDir = Vector2.ZERO
		else:
			targetPos = controller.tileToWorld(tilePos + movingDir)
			
	else:
		position = position.move_toward(targetPos, 200 * delta)
		if (position == targetPos):
			tilePos = controller.worldToTile(position)
			movingDir = Vector2.ZERO
			targetPos = null