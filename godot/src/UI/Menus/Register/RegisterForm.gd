# Interface to register a new account.
extends Menu

signal register_pressed(email, password, do_remember_email)
signal cancel_pressed

@onready var register_button: Button = $VBoxContainer/HBoxContainer/RegisterButton
@onready var cancel_button: Button = $VBoxContainer/HBoxContainer/CancelButton

@onready var email_field: LineEdit = $VBoxContainer/Email/LineEditValidate
@onready var password_field: LineEdit = $VBoxContainer/Password/LineEditValidate
@onready var password_field_repeat: LineEdit = $VBoxContainer/PasswordRepeat/LineEditValidate

@onready var remember_email: CheckBox = $VBoxContainer/RememberEmail
@onready var status_panel := $VBoxContainer/StatusPanel


func set_is_enabled(value: bool) -> void:
	super.set_is_enabled(value)
	if not cancel_button:
		await self.ready
	cancel_button.disabled = not value
	register_button.disabled = not value
	email_field.editable = value
	password_field.editable = value
	password_field_repeat.editable = value


func set_status(text: String) -> void:
	super.set_status(text)
	status_panel.text = text


func reset() -> void:
	super.reset()
	self.status = ""
	password_field.text = ""
	password_field_repeat.text = ""
	email_field.text = ""


func attempt_register() -> void:
	if email_field.text.is_empty():
		self.status = "Email cannot be empty"
		return
	elif password_field.text.is_empty() or password_field_repeat.text.is_empty():
		self.status = "Password cannot be empty"
		return
	elif password_field.text.similarity(password_field_repeat.text) != 1:
		self.status = "Passwords do not match"
		return

	emit_signal("register_pressed", email_field.text, password_field.text, remember_email.pressed)


func _on_RegisterButton_pressed() -> void:
	attempt_register()


func _on_CancelButton_pressed() -> void:
	emit_signal("cancel_pressed")
	hide()


# Connected to all three LineEditValidate in the scene
func _on_text_changed(_new_text: String) -> void:
	attempt_register()


func _on_open() -> void:
	email_field.grab_focus()
