# Control panel that manages logging into an existing account.
extends Menu

signal register_pressed
signal login_pressed(email, password, do_remember_email)

@onready var remember_email := $VBoxContainer/RememberEmail

@onready var email_field := $VBoxContainer/Email/LineEditValidate
@onready var password_field := $VBoxContainer/Password/LineEditValidate
@onready var login_button := $VBoxContainer/HBoxContainer/LoginButton
@onready var register_button := $VBoxContainer/HBoxContainer/RegisterButton

@onready var status_panel := $VBoxContainer/StatusPanel
#$VBoxContainer/StatusPanel


func _ready() -> void:
	email_field.text = ServerConnection.get_last_email()
	if not email_field.text.is_empty():
		remember_email.button_pressed = true

	email_field.grab_focus()


func set_is_enabled(value: bool) -> void:
	super.set_is_enabled(value)
	if not email_field:
		await self.ready
	email_field.editable = is_enabled
	password_field.editable = is_enabled
	remember_email.disabled = not is_enabled
	login_button.disabled = not is_enabled
	register_button.disabled = not is_enabled


func set_status(text: String) -> void:
	super.set_status(text)
	status_panel.text = text


func reset() -> void:
	super.reset()
	self.status = ""
	password_field.text = ""
	if not remember_email.pressed:
		email_field.text = ""


func attempt_login() -> void:
	if not email_field.is_valid:
		status_panel.text = "The email address is not valid"
		return
	if password_field.text == "":
		status_panel.text = "Please enter your password to log in"
		return
	if password_field.text.length() < 8:
		status_panel.text = "The password should be at least 8 characters long"
		return

	emit_signal("login_pressed", email_field.text, password_field.text, remember_email.button_pressed)
	#print(login_pressed.get_connections())
	status_panel.text = "Authenticating..."


func _on_LoginButton_pressed() -> void:
	attempt_login()


func _on_RegisterButton_pressed() -> void:
	emit_signal("register_pressed")


func _on_LineEditValidate_text_entered(_new_text: String) -> void:
	attempt_login()


func _on_open() -> void:
	email_field.grab_focus()
