extends MenuButton

func _ready():
	var popup = get_popup()
	popup.add_item("Mauern", 0)
	popup.add_item("Räume", 1)
	
	connect("mouse_entered",self,"on_mouse_entered")
	connect("pressed",self,"on_mouse_pressed")
	popup.connect("id_pressed", self, "popup_button_pressed")

func on_mouse_entered():
	GV.sound_player.play_effect(GV.sound_player.BUTTON_HOVER)

func on_mouse_pressed():
	GV.sound_player.play_effect(GV.sound_player.BUTTON_CLICK)

func popup_button_pressed(id):
	on_mouse_pressed()
	match(id):
		0: construct_walls()
		1: construct_rooms()

func construct_walls():
	GV.shop_screen.show_tiles_for_wall()

func construct_rooms():
	GV.shop_screen.reset_construction_options()
	GV.shop_screen.show_construc_room_menue()
