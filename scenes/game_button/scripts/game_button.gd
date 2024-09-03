extends Button

signal focused(who: Button)

var game_name: String 
var properties: Dictionary
var tween: Tween

@onready var capsule: TextureRect = $Capsule
@onready var cross = $Cross
@onready var gradient: TextureRect = $Gradient
@onready var info_container: HBoxContainer = $InfoContainer
@onready var platform: Label = $InfoContainer/PlatformContainer/Platform
@onready var player_nb: Label = $InfoContainer/PlayerContainer/PlayerNb

func _ready() -> void:
	pivot_offset = size / 2.0
	
	cross.visible = false
	gradient.modulate.a = 0.0
	info_container.modulate.a = 0.0
	
	platform.text = ""
	player_nb.text = ""
	
	if properties.has("capsule"):
		var tex: ImageTexture = load_image_texture(properties["capsule"])
		if tex:
			capsule.texture = tex
		
	if properties.has("platforms"):
		platform.text = properties["platforms"]
	
	if properties.has("release_date"):
		if properties["release_date"] != "":
			platform.text += " · " + properties["release_date"]
	
	if properties.has("players_nb"):
		player_nb.text = properties["players_nb"]

func load_image_texture(path: String) -> ImageTexture:
	var capsule_im: Image = Image.new()
	if capsule_im.load(path) != OK:
		print("BAD STUFF, CANT LOAD CAPSULE AT: ", properties["capsule"])
		return null
	else:
		var tex: ImageTexture = ImageTexture.new()
		tex.set_image(capsule_im)
		return tex

func toggle_focus_visuals(state: bool) -> void:
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	if state:
		tween.tween_property(self, "scale", Vector2(1.15, 1.15), 0.2)
		if platform.text != "" or player_nb.text != "":
			tween.parallel().tween_property(info_container, "modulate:a", 1.0, 0.25)
			tween.parallel().tween_property(gradient, "modulate:a", 1.0, 0.25)
		#tween.tween_property(self, "rotation_degrees", 360.0, 0.2).from(0.0)
	else:
		tween.tween_property(self, "scale", Vector2.ONE, 0.4)
		if platform.text != "" or player_nb.text != "":
			tween.parallel().tween_property(info_container, "modulate:a", 0.0, 0.25)
			tween.parallel().tween_property(gradient, "modulate:a", 0.0, 0.25)
		#tween.tween_property(self, "rotation_degrees", -360.0, 0.3).from(0.0)

func _on_focus_entered() -> void:
	focused.emit(self)
	toggle_focus_visuals(true)

func _on_mouse_entered() -> void:
	focused.emit(self)
	toggle_focus_visuals(true)

func _on_focus_exited():
	toggle_focus_visuals(false)

func _on_mouse_exited():
	toggle_focus_visuals(false)

func _on_toggled(toggled_on):
	cross.visible = toggled_on
