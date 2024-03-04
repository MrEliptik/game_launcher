extends Button

signal focused(who: Button)

var game_name: String 
var properties: Dictionary

@onready var capsule: TextureRect = $Capsule
@onready var cross = $Cross

func _ready() -> void:
	if properties.has("capsule"):
		var tex: ImageTexture = load_image_texture(properties["capsule"])
		if not tex: return
		capsule.texture = tex

func load_image_texture(path: String) -> ImageTexture:
	var capsule_im: Image = Image.new()
	if capsule_im.load(path) != OK:
		print("BAD STUFF, CANT LOAD CAPSULE AT: ", properties["capsule"])
		return null
	else:
		var tex: ImageTexture = ImageTexture.new()
		tex.set_image(capsule_im)
		return tex

func _on_focus_entered() -> void:
	focused.emit(self)

func _on_mouse_entered() -> void:
	focused.emit(self)

func _on_toggled(toggled_on):
	cross.visible = toggled_on
