extends Control

const diameter = 35
export var windAngle = 0 setget _set_angle
export var windSpeed = 0 setget _set_speed # MPH?


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _draw():
	var radAng = deg2rad(windAngle)
	var lineEnd = diameter / 2 * Vector2(sin(radAng), cos(radAng))
	
	draw_circle(Vector2(0, 0), diameter / 2, Color(0x454545FF))
	draw_line(Vector2(0, 0), lineEnd, Color(1, 0, 0), 1, true)

func _set_angle(value):
	update()

func _set_speed(value):
	pass #TODO: dispatch to label child
