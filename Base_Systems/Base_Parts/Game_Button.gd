extends Button
class_name Game_Button

var sound_effect_hover_id = GV.sound_player.BUTTON_HOVER
var sound_effect_click_id = GV.sound_player.BUTTON_CLICK

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("mouse_entered",self,"on_mouse_entered")
	connect("pressed",self,"on_mouse_pressed")

func on_mouse_entered():
	GV.sound_player.play_effect(sound_effect_hover_id)

func on_mouse_pressed():
	GV.sound_player.play_effect(sound_effect_click_id)
