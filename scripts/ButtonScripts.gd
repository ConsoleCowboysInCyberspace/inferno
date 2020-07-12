extends Node

func switch_scene(path):
	call_deferred("_switch_callback", path)

func _switch_callback(path):
	tile_manager.set_process(false)
	tile_manager.set_physics_process(false)
	tile_manager.nukeItFromOrbit()
	get_tree().change_scene(path)

func quit_game():
	get_tree().quit()
