extends LinkButton

func _ready():
	text = ProjectSettings.get_setting("application/config/version")
