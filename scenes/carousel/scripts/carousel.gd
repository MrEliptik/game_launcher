extends Control

@export var button_offset: Vector2

var tween: Tween

var can_move: bool = true
var can_move_right: bool = true
var can_move_left: bool = true

func _ready():
	pass # Replace with function body.

func _input(event: InputEvent):
	if event.is_action_pressed("ui_left"):
		if can_move_left:
			can_move_left = false
			move_left()
		get_viewport().set_input_as_handled()
	elif event.is_action_released("ui_left") and not can_move_left:
		can_move_left = true
		get_viewport().set_input_as_handled()
		
	if event.is_action_pressed("ui_right"):
		if can_move_right:
			can_move_right = false
			move_right()
		get_viewport().set_input_as_handled()
	elif event.is_action_released("ui_right") and not can_move_right:
		can_move_right = true
		get_viewport().set_input_as_handled()

func _process(delta: float) -> void:
	return
	if Input.is_action_just_pressed("ui_left"):
		print("Left: ", Input.get_action_strength("ui_left"))
		if can_move:
			move_left()
		get_viewport().set_input_as_handled()
	elif Input.is_action_just_pressed("ui_right"):
		print("Right: ", Input.get_action_strength("ui_right"))
		if can_move:
			move_right()
		get_viewport().set_input_as_handled()

func create_game_buttons(game_button: PackedScene, to_create: Dictionary) -> Array:
	var game_buttons: Array = []
	for key in to_create.keys():
		if to_create[key].has("visible"):
			if not to_create[key]["visible"]: continue
		
		var instance: Button = game_button.instantiate()
		instance.game_name = key
		instance.properties = to_create[key]
		game_buttons.append(instance)
		
		# disable non playable games
		var playable: bool =  instance.properties.get("playable") if instance.properties.get("playable") else false
		instance.disabled = not playable
		
	# Sort using order values
	game_buttons.sort_custom(sort_btns_ascending)
	
	# Add child in the correct order
	var count: int = 0
	for btn in game_buttons:
		add_child(btn)
		btn.position -= btn.size / 2.0
		btn.position.x += (btn.size.x + button_offset.x) * count
		count += 1
		
	
	if get_child_count() > 0: 
		# Call deferred to make sure the app has time to connect focus signal and react accordingly
		get_child(0).call_deferred("grab_focus")
		
	return get_children() 

func sort_btns_ascending(a, b):
	if not a.properties.has("order") and not b.properties.has("order"): return false
	if not a.properties.has("order") and b.properties.has("order"): return false
	if a.properties.has("order") and not b.properties.has("order"): return true
	if a.properties["order"] < b.properties["order"]:
		return true
	return false

func move_left() -> void:
	var idx: int = 0
	if get_viewport().gui_get_focus_owner():
		idx = get_viewport().gui_get_focus_owner().get_index()
		
	if idx == 0: return
	
	var next_idx: int = idx - 1
	
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC).set_parallel(true)
	# Get the currently selected button id
	for i in range(get_child_count()):
		var c: Button = get_child(i)
		var diff: int = next_idx - i
		tween.tween_property(c, "position:x", -(c.size.x/2.0) - ((c.size.x + button_offset.x) * diff), 0.3)
	
	#Old method, will bug out if you go too fast
	#for i in range(get_child_count()):
		#var c: Button = get_child(i)
		#tween.tween_property(c, "position:x", c.position.x + (c.size.x + button_offset.x), 0.3)
		#tween.tween_property(c, "rotation_degrees", 360.0, 0.3).from(0.0)
		#c.position.x += (c.size.x + button_offset.x)
	
	# Select the next button
	get_child(idx - 1).grab_focus()

func move_right() -> void:
	var idx: int = 0
	if get_viewport().gui_get_focus_owner():
		idx = get_viewport().gui_get_focus_owner().get_index()
		
	if idx == get_child_count() - 1: return
	
	var next_idx: int = idx + 1
	
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC).set_parallel(true)
	
	for i in range(get_child_count()):
		var c: Button = get_child(i)
		var diff: int = i - next_idx
		# -(c.size.x/2.0) is to offset the button to be in the center, otherwise it's positionned
		# with the top left corner
		tween.tween_property(c, "position:x", -(c.size.x/2.0) + ((c.size.x + button_offset.x) * diff), 0.3)
	
	#Old method, will bug out if you go too fast
	#for i in range(get_child_count()):
		#var c: Button = get_child(i)
		#tween.tween_property(c, "position:x", c.position.x - (c.size.x + button_offset.x), 0.3)
		
		#tween.tween_property(c, "rotation_degrees", 360.0, 0.3).from(0.0)
		#c.position.x -= (c.size.x + button_offset.x)

	# Select the next button
	get_child(idx + 1).grab_focus()
