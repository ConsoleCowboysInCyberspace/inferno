extends Node

func switch_scene(path):
    get_tree().change_scene(path)

func quit_game():
    get_tree().quit()
