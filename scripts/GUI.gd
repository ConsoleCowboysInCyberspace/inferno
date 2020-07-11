extends CanvasLayer

onready var score = find_node("Score")
onready var waterBar = find_node("WaterBar")
onready var anemometer = find_node("Anemometer")

# temp debug code
var lastUpdateTime = 0
func _process(delta):
	var now = OS.get_ticks_msec() / 1000
	
	if now - lastUpdateTime > 1:
		lastUpdateTime = now
		
		set_score(randi() % 10000)
		set_water_level(randi() % 100)
		set_wind_angle(randi() % 360)
		set_wind_speed(randi() % 100)

func set_score(value):
	score.bbcode_text = "[right]" + String(value) + "[/right]"

func set_water_level(value):
	waterBar.value = value

func set_wind_angle(value):
	anemometer.windAngle = value

func set_wind_speed(value):
	anemometer.windSpeed = value
