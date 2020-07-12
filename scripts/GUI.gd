extends CanvasLayer

onready var score = find_node("Score")
onready var healthBar = find_node("HealthBar")
onready var waterBar = find_node("WaterBar")
onready var anemometer = find_node("Anemometer")

# fire arrow
export var arrow_visible_time = 15
onready var newFireArrow = find_node("NewFireArrow") # TODO
onready var fireArrowSprite = newFireArrow.get_node("Sprite")
onready var arrowTimer = Timer.new()
var arrowTarget : Vector2

func _ready():

	# setting up fire arrow
	tile_manager.connect("windFireStarted", self, "new_fire_started")
	arrowTimer.connect("timeout", self, "arrowTimerTimeout")
	add_child(arrowTimer)
	arrowTimer.one_shot = true

func _process(delta):
	# poll score like a pleb
	set_score(tile_manager.score)
	
	# rotate arrow to face target
	#var toTarget = arrowTarget - newFireArrow.position
	fireArrowSprite.rotation = tile_manager.truck.global_position.angle_to_point(arrowTarget) + PI

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
	arrowTarget = tile_manager.tileToWorld(pos)
	newFireArrow.visible = true
	arrowTimer.start(arrow_visible_time)

func arrowTimerTimeout():
	newFireArrow.visible = false

func on_death():
	var gameover = $gameover
	gameover.visible = true
	gameover.get_node("RichTextLabel").text = "Your Score: " + String(tile_manager.score)
	gameover.get_node("TextureButton").disabled = false
