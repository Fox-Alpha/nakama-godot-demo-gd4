extends LineEditValidate


func _validate(intext: String) -> bool:
	return intext.length() >= 8
