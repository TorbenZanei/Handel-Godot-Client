extends TextureButton
class_name Textur_Game_Button

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("mouse_entered",self,"on_mouse_entered")
	connect("pressed",self,"on_mouse_pressed")

func on_mouse_entered():
	GV.sound_player.play_effect(GV.sound_player.BUTTON_HOVER)

func on_mouse_pressed():
	GV.sound_player.play_effect(GV.sound_player.BUTTON_CLICK)
