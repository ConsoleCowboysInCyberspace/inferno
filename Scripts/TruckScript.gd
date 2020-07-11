extends Node2D

var xPos : int
var yPos : int
var isMoving : bool
var movingUp : bool
var movingDown : bool
var movingLeft : bool
var movingRight : bool
export var squareSize : float
var velocity = Vector2()
export var speed : int
var initialX : float
var initialY : float
var moveTimer # moveTimer is so that you make sure to move at least a little bit, so it doesn't go "But I'm ALREADY right on a tile!"

# Called when the node enters the scene tree for the first time.
func _ready():
	xPos = 10
	yPos = 10
	initialX = position.x
	initialY = position.y
	moveTimer = 3

func _process(delta):
	if !isMoving:
		if Input.is_action_pressed("truck_up"):
				isMoving    = true
				movingUp    = true
		if Input.is_action_pressed("truck_down"):
				isMoving    = true
				movingDown  = true
		if Input.is_action_pressed("truck_left"):
				isMoving    = true
				movingLeft  = true
		if Input.is_action_pressed("truck_right"):
				isMoving    = true
				movingRight = true
	if movingUp:
		moveTimer -= 1
		print("Modulus: " + str(fmod(initialY-position.y, squareSize)))
		if fmod(initialY-position.y, squareSize) != 0 || moveTimer > 1:
			velocity.y -= speed
		else:
			_stop()
			yPos -= 1
	elif movingDown:
		moveTimer -= 1
		if fmod(initialY-position.y, squareSize) != 0 || moveTimer > 1:
			velocity.y += speed
		else:
			_stop()
			yPos += 1
	elif movingLeft:
		moveTimer -= 1
		if fmod(initialX-position.x, squareSize) != 0 || moveTimer > 1:
			velocity.x -= speed
		else:
			_stop()
			xPos -= 1
	elif movingRight:
		moveTimer -= 1
		if fmod(initialX-position.x, squareSize) != 0 || moveTimer > 1:
			velocity.x += speed
		else:
			_stop()
			xPos += 1
	else:
		_stop()
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
	position += velocity
	print (str(velocity.x) + "  " + str(position.x))

func _stop():
	movingRight = false
	movingLeft  = false
	movingUp    = false
	movingDown  = false
	isMoving    = false
	velocity.x = 0
	velocity.y = 0
	moveTimer = 3
