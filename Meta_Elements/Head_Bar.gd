extends Panel


# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("Screen_Menue/Shop_Button").connect("pressed",self,"switch_to_shop_screen")
	get_node("Screen_Menue/Storage_Button").connect("pressed",self,"switch_to_storage_screen")
	get_node("Screen_Menue/Market_Button").connect("pressed",self,"switch_to_market_screen")
	
	get_node("Screen_Menue/Shop_Button").connect("mouse_entered",self,"on_mouse_entered")
	get_node("Screen_Menue/Storage_Button").connect("mouse_entered",self,"on_mouse_entered")
	get_node("Screen_Menue/Market_Button").connect("mouse_entered",self,"on_mouse_entered")
	
	update_actual_money()
	update_actual_workforce()
	GV.global_timer.connect("timeout", self, "update_clock")

#Wechselt in das Shop Fenster
func switch_to_shop_screen():
	GV.shop_screen.switch_screen(1)
	GV.sound_player.play_effect(GV.sound_player.BUTTON_CLICK)

#Wechselt in das Lager Fenster
func switch_to_storage_screen():
	GV.shop_screen.switch_screen(2)
	GV.sound_player.play_effect(GV.sound_player.BUTTON_CLICK)

#Wechselt in das Markt Fenster
func switch_to_market_screen():
	GV.shop_screen.switch_screen(3)
	GV.sound_player.play_effect(GV.sound_player.BUTTON_CLICK)

#Mouse Over
func on_mouse_entered():
	GV.sound_player.play_effect(GV.sound_player.BUTTON_HOVER)

#Aktualisiert die Geldanzeige in der Kopfzeile
func update_actual_money():
	get_node("Money_Label").text = String(GV.actual_money) + "$"

#Aktualisert die Arbeiteranzeige in der Kopfzeile
func update_actual_workforce():
	get_node("Workforce_Label").text = "Freie Arbeiter: " + String(GV.actual_workforce[1]) + "/" + String(GV.actual_workforce[0])

#Aktualisiert die Uhr in der Kopfzeile (wird jede Sekunde ausgeführt)
func update_clock():
	get_node("Clock_Label").text = GV.get_actual_time()
