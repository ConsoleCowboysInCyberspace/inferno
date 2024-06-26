tool
extends Control

export var windAngle = 0 setget _set_angle
export var windSpeed = 0 setget _set_speed # MPH?

const diameter = 35
onready var speedLabel = get_parent().find_node("WindSpeed")

func _ready():
	Wind.connect("wind_angle_changed", self, "_set_angle")
	Wind.connect("wind_speed_changed", self, "_set_speed")
	
	windAngle = Wind.wind_angle
	windSpeed = Wind.wind_speed

func _draw():
	var radAng = deg2rad(windAngle)
	var lineEnd = diameter / 2 * Vector2(cos(radAng), sin(radAng))
	
	draw_circle(Vector2(0, 0), diameter / 2, Color(0x454545FF))
	draw_line(Vector2(0, 0), lineEnd, Color(1, 0, 0), 1, true)

func _set_angle(value):
	windAngle = value
	
	update()

func _set_speed(value):
	speedLabel.bbcode_text = String(value) + " MPH"
