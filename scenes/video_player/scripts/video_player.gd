extends VideoStreamPlayer

class_name VideoPlayer

@export var timeout_before_play: float = 10.0

var game_running: bool = false

@onready var timer: Timer = Timer.new()

func _ready() -> void:
	SignalBus.game_launched.connect(func(): game_running = true)
	SignalBus.game_closed.connect(func(): 
		game_running = false
		#timer.start()
	)
	
	#add_child(timer)
	#timer.one_shot = true
	#timer.wait_time = timeout_before_play
	#timer.start()
	#visible = false
	#
	#timer.timeout.connect(on_timer_timeout)

func _input(event: InputEvent) -> void:
	if game_running or not visible: return
	
	# Check if any input to stop the player and restart the timer
	if event is InputEventMouseButton or event is InputEventJoypadButton \
		or event is InputEventKey:
			stop_video()
			#timer.start()
			# Prevent the rest of the app from reacting to this event
			get_viewport().set_input_as_handled()

func play_video() -> void:
	show()
	play()
	
func stop_video() -> void:
	hide()
	stop()

func on_timer_timeout() -> void:
	return
	if game_running: return
	visible = true
	play()
