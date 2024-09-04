extends Node

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func _notification(what: int) -> void:
	return
	if what == NOTIFICATION_WM_WINDOW_FOCUS_IN:
		print("Focus enter")
		get_tree().paused = false
	elif what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		print("Focus exit")
		get_tree().paused = true
