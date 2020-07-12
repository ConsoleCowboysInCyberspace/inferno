extends CanvasLayer

onready var score = find_node("Score")
onready var healthBar = find_node("HealthBar")
onready var waterBar = find_node("WaterBar")
onready var anemometer = find_node("Anemometer")

onready var newFireArrow = find_node("NewFireArrow") # TODO
var arrowTarget : Vector2

func _ready():
	tile_manager.connect("windFireStarted", self, "new_fire_started")

# temp debug code
var lastUpdateTime = 0
func _process(delta):

	# not debug code

	var now = OS.get_ticks_msec() / 1000
	
	if now - lastUpdateTime > 1:
		lastUpdateTime = now
		
		set_score(now)
		# set_water_level(randi() % 100)
		# set_wind_angle(randi() % 360)
		# set_wind_speed(randi() % 100)

func set_score(value):
	score.bbcode_text = "[right]" + String(value) + "[/right]"

func set_health(value):
	healthBar.value = value

func set_water_level(value):
	waterBar.value = value

func set_wind_angle(value):
	anemometer.windAngle = value

func set_wind_speed(value):
	anemometer.windSpeed = value

func new_fire_started(pos):
	pass
