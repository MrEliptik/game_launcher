extends Control

@export var game_button: PackedScene
@export var default_bg: Texture

var pid_watching: int = -1
var games: Dictionary
var curr_game_btn: Button = null

@onready var bg: TextureRect = $BG
@onready var timer: Timer = Timer.new()
@onready var games_container: Control = $Games
@onready var no_game_found = $NoGameFound
@onready var title: Label = $PanelContainer/Description/Title
@onready var description: Label = $PanelContainer/Description/Description
@onready var version_btn = $VersionBtn

@onready var update_checker := UpdateChecker.new()

func _ready() -> void:
	add_child(update_checker)
	update_checker.get_latest_version()
	update_checker.release_parsed.connect(on_released_parsed)
	
	configure_timer()
	var base_dir: String = ProjectSettings.globalize_path("res://") if OS.has_feature("editor") else OS.get_executable_path().get_base_dir()
	create_game_folder(base_dir)
	parse_games(base_dir.path_join("games"))
	
	if games.is_empty():
		no_game_found.visible = true
	
	var buttons: Array = games_container.create_game_buttons(game_button, games)
	for b in buttons:
		b.focused.connect(on_game_btn_focused)
		b.toggled.connect(on_game_btn_toggled.bind(b))
	
	# Test
	#launch_game("Dashpong")

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		print("About to quit, killing process")
		stop_game(pid_watching)
		
		# Maybe use a softer method, by sending a WM_CLOSE message first
		# windows only
		# NOT TESTED YET
		#taskkill /PID pid_watching
		#OS.execute(taskkill, ("/PID", str(pid_watching)])

func _input(event):
	if Input.is_action_just_pressed("toggle_fullscreen"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			
	if event.is_action_pressed("kill"):
		stop_game(pid_watching)

func configure_timer() -> void:
	add_child(timer)
	# Configure the timer
	timer.one_shot = false
	timer.wait_time = 1.0
	timer.timeout.connect(on_timer_timeout)

func create_game_folder(base_dir: String) -> void:
	var dir = DirAccess.open(base_dir)
	if dir.dir_exists(base_dir.path_join("games")): return
	dir.make_dir(base_dir.path_join("games"))

func parse_games(path: String) -> void:
	var dir = DirAccess.open(path)
	
	dir.include_hidden = false
	dir.include_navigational = false
	
	if not dir: 
		print("An error occurred when trying to access the path.")
		return
		
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		# We found a game, explore its content
		if dir.current_is_dir():
			print("Found directory: " + file_name)
			games[file_name] = {}
			var subdir_path: String = path.path_join(file_name)
			var subdir = DirAccess.open(subdir_path)
			subdir.list_dir_begin()
			var file = subdir.get_next()
			while file != "":
				if not subdir.current_is_dir():
					var extension: String = file.get_extension().to_lower()
					#TODO: make functionnal with other platforms: mac
					match extension:
						"exe", "x86_64":
							print(subdir.get_current_dir())
							games[file_name]["executable"] = subdir.get_current_dir().path_join(file)
						"jpg", "jpeg", "png":
							if file.get_basename() == "capsule":
								games[file_name]["capsule"] = subdir.get_current_dir().path_join(file)
							elif file.get_basename() == "bg":
								games[file_name]["bg"] = subdir.get_current_dir().path_join(file)
						"txt":
							if file.get_basename() == "description":
								var text_file = FileAccess.open(subdir.get_current_dir().path_join(file), FileAccess.READ)
								var content = text_file.get_as_text()
								games[file_name]["description"] = content
					
				file = subdir.get_next()
			
		file_name = dir.get_next()
	print("Games: ", games)
	
func launch_game(game_name: String) -> void:
	if not games[game_name].has("executable"): return
	games_container.can_move = false
	var executable_path: String = games[game_name]["executable"]
	pid_watching = OS.create_process(executable_path, [])
	timer.start()

func stop_game(pid: int) -> void:
	if pid_watching < 0: return
	games_container.can_move = true
	OS.kill(pid)

func on_timer_timeout() -> void:
	if OS.is_process_running(pid_watching):
		print("Running")
	else:
		print("Stopped")
		timer.stop()
		pid_watching = -1
		if curr_game_btn:
			curr_game_btn.button_pressed = false
		games_container.can_move = true
		DisplayServer.window_move_to_foreground()

func on_game_btn_focused(who: Button) -> void:
	if not who.properties.has("description"):
		description.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
	else:
		description.text = who.properties["description"]
	
	title.text = who.game_name

	if not who.properties.has("bg"): 
		#bg.texture = default_bg
		bg.blend_textures_animated(bg.get_shader_texture(1), default_bg, 0.4)
		return
	var texture: ImageTexture = who.load_image_texture(who.properties["bg"])
	if not texture: 
		bg.blend_textures_animated(bg.get_shader_texture(1), default_bg, 0.4)
		#bg.texture = default_bg
		return
	bg.blend_textures_animated(bg.get_shader_texture(1), texture, 0.4)
	#bg.texture = texture

func on_game_btn_toggled(state: bool, btn: Button) -> void:
	# If game already launched, don't launch another one
	if state:
		if pid_watching > 0: return
		games_container.can_move = false
		launch_game(btn.game_name)
		curr_game_btn = btn
	else:
		stop_game(pid_watching)

func on_released_parsed(release: Dictionary) -> void:
	print("release: ", release["version"])

	if release["new"]:
		version_btn.text = "New version available: " + release["version"]
	else:
		version_btn.text = "You have the latest version: " + release["version"]
	version_btn.uri = release["url"]
