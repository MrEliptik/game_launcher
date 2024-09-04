extends Node

class_name GlobalShortcut

var ws_socket: WebSocketPeer = WebSocketPeer.new()
var websocket_url = "ws://localhost:65432"

func _init() -> void:
	set_process(false)
	if ws_socket.connect_to_url(websocket_url) != OK:
		print("Could not connect.")
		return
		
	print("Connected to: ", websocket_url)
	
	var timer: Timer = Timer.new()
	timer.one_shot = false
	timer.timeout.connect(process_ws)
	Engine.get_main_loop().root.add_child.call_deferred(timer)
	timer.start.call_deferred(0.5)

func _ready():
	set_process(false)
	if ws_socket.connect_to_url(websocket_url) != OK:
		print("Could not connect.")
		return
		
	print("Connected to: ", websocket_url)
	
	var timer: Timer = Timer.new()
	timer.one_shot = false
	timer.timeout.connect(process_ws)
	add_child(timer)
	timer.start(0.5)
	
func process_ws() -> void:
	ws_socket.poll()
	
	if ws_socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		while ws_socket.get_available_packet_count():
			print("WS received: ", ws_socket.get_packet().get_string_from_ascii())
			# No need to check what the message is, we know we receive a signal only
			# when the shortcut we want is pressed
			SignalBus.shortcut_close_game_pressed.emit()
	elif ws_socket.get_ready_state() == WebSocketPeer.STATE_CLOSING:
		print("WS closing")
	elif ws_socket.get_ready_state() == WebSocketPeer.STATE_CLOSED:
		print("WS closed")

func _exit_tree():
	ws_socket.close()
