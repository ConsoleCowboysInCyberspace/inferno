extends TextureButton

var path = "res://Scenes/main_title.tscn"

func _ready():
	connect("pressed", self, "on_pressed")


func on_pressed():
	call_deferred("_switch_callback", path)

func _switch_callback(path):
	tile_manager.set_process(false)
	tile_manager.set_physics_process(false)
	tile_manager.nukeItFromOrbit()
	get_tree().change_scene(path)


