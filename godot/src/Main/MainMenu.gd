# Handles communication with the server, character creation, etc. for the main menus.
# The menus send signals to this node, and `MainMenu` processes the data or forwards it to the 
# server.
extends Node

# Maximum number of times to retry a server request if the previous attempt failed.
const MAX_REQUEST_ATTEMPTS := 3

# Path to the scene to load after selecting a character.
@export var next_scene_path := ""

var _server_request_attempts := 0

#@onready var login_and_register := $CanvasLayer/LoginAndRegister
@onready var login_and_register := $"CanvasLayer/LoginAndRegister"
@onready var character_menu := $"CanvasLayer/CharacterMenu"


# Requests the server to authenticate the player using their credentials.
# Attempts authentication up to `MAX_REQUEST_ATTEMPTS` times.
func authenticate_user_async(email: String, password: String, do_remember_email := false) -> int:
	var result := -1

	login_and_register.is_enabled = false
	while result != OK:
		if _server_request_attempts == MAX_REQUEST_ATTEMPTS:
			break
		_server_request_attempts += 1
		result = await ServerConnection.login_async(email, password)

	if result == OK:
		if do_remember_email:
			ServerConnection.save_email(email)
		open_character_menu_async()
	else:
		login_and_register.status = "Error code %s: %s" % [result, ServerConnection.error_message]
		login_and_register.is_enabled = true

	_server_request_attempts = 0
	return result


# Asks the server to create a new character asynchronously.
# Returns a dictionary with the player's name and color if it worked.
# Otherwise, returns an empty dictionary.
func create_character_async(plyname: String, color: Color) -> Dictionary:
	character_menu.is_enabled = false

	var result: int = await ServerConnection.create_player_character_async(color, plyname)

	var data := {}
	if result == OK:
		data = {plyname = plyname, color = color}
		character_menu.add_character(plyname, color)
		ServerConnection.store_last_player_character_async(plyname, color)
	elif result == ERR_UNAVAILABLE:
		printerr("Character %s unavailable." % plyname)

	character_menu.is_enabled = true
	return data


# Asks the server to delete a character asynchronously.
func delete_character_async(index: int) -> void:
	character_menu.is_enabled = false
	var result: int = await ServerConnection.delete_player_character_async(index)

	if result == OK:
		character_menu.delete_character(index)
	character_menu.is_enabled = true


# Attempts to connect to the server, then to join the world match.
func join_game_world_async(player_name: String, player_color: Color) -> int:
	character_menu.is_enabled = false

	var result: int = await ServerConnection.connect_to_server_async()
	if result == OK:
		result = await ServerConnection.join_world_async()
	if result == OK:
		# warning-ignore:return_value_discarded
		get_tree().change_scene_to(load("res://src/Main/GameWorld.tscn"))
		ServerConnection.send_spawn(player_color, player_name)

	character_menu.is_enabled = true
	return result


func open_character_menu_async() -> void:
	var characters: Array = await ServerConnection.get_player_characters_async()
	var last_played_character: Dictionary = await ServerConnection.get_last_player_character_async()
	character_menu.setup(characters, last_played_character)
	login_and_register.hide()
	character_menu.show()


# Deactivates the user interface and authenticates the user.
# If the server authenticated the user, goes to the game level scene.
func _on_LoginAndRegister_login_pressed(email: String, password: String, do_remember_email: bool) -> void:
	login_and_register.status = "Authenticating..."
	login_and_register.is_enabled = false

	await authenticate_user_async(email, password, do_remember_email)

	login_and_register.is_enabled = true


# Deactivates the user interface, registers, and authenticates the user.
# If the server authenticated the user, goes to the game level scene.
func _on_LoginAndRegister_register_pressed(email: String, password: String, do_remember_email: bool) -> void:
	login_and_register.status = "Authenticating..."
	login_and_register.is_enabled = false

	var result: int = await ServerConnection.register_async(email, password)
	if result == OK:
		await authenticate_user_async(email, password, do_remember_email)
	else:
		login_and_register.status = "Error code %s: %s" % [result, ServerConnection.error_message]

	login_and_register.is_enabled = true


func _on_CharacterMenu_character_deletion_requested(index: int) -> void:
	delete_character_async(index)


func _on_CharacterMenu_new_character_requested(plyname: String, color: Color) -> void:
	await create_character_async(plyname, color)
	await join_game_world_async(plyname, color)


func _on_CharacterMenu_character_selected(plyname: String, color: Color) -> void:
	await join_game_world_async(plyname, color)


func _on_CharacterMenu_go_back_requested() -> void:
	login_and_register.reset()
	character_menu.reset()
	character_menu.hide()
	login_and_register.show()
