extends Node

export var wind_speed = 0
export var wind_angle = 0

signal wind_speed_changed(wind_speed)
signal wind_angle_changed(wind_angle)

var speed_noise # simplex noise :^)
var last_speed = 0 # last time we updated speed
var speed_time = 0 # input to noise generator
const speed_delay = 0.5 # seconds between speed updates
const speed_step = 2 # how fast we increment time

var angle_noise
var last_angle = 0
var angle_time = 0
const angle_delay = 0.1
const angle_step = 0.75

func _ready():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	speed_noise = OpenSimplexNoise.new()
	speed_noise.seed = rng.randi()
	angle_noise = OpenSimplexNoise.new()
	angle_noise.seed = rng.randi()
	
	_physics_process(1) # set initial values

func _physics_process(delta):
	var now = OS.get_ticks_msec() / 1000.0
	
	if now - last_speed > speed_delay:
		last_speed = now
		wind_speed = int(60 + 50 * speed_noise.get_noise_1d(speed_time))
		speed_time += speed_step
		
		emit_signal("wind_speed_changed", wind_speed)
		print("speed", wind_speed)
	
	if now - last_angle > angle_delay:
		last_angle = now
		wind_angle = 360 * angle_noise.get_noise_1d(angle_time)
		angle_time += angle_step
		
		emit_signal("wind_angle_changed", wind_angle)
		print("angle", wind_angle)
