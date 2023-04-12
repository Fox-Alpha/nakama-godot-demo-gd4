# Game-wide inputs and other controls that should work in every scene.
extends Node


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_fullscreen"):
#		OS.window_fullscreen = not OS.window_fullscreen

		if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		
