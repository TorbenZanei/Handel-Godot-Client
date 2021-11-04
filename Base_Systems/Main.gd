extends Panel

const Login_Screen = preload("res://Login_Screen/Login_Screen.tscn")
const Shop_Screen = preload("res://Shop_Screen/Shop_Screen.tscn")
const Popup_Message = preload("res://Base_Systems/Popup_Message.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	GV.main = self
	GV.login_screen = Login_Screen.instance()
	GV.shop_screen = Shop_Screen.instance()
	GV.popup_message = Popup_Message.instance()
	
	add_child(GV.login_screen)
	add_child(GV.global_timer)
	add_child(GV.sound_player)
	GV.login_screen.add_child(GV.popup_message)
	
	GV.start_time()

#Fordert nach erfolgreichem login die aktuellen Warendaten und den eigenen Spielstand an
func succesfull_login():
	GV.login_screen.remove_child(GV.popup_message)
	remove_child(GV.login_screen)
	add_child(GV.shop_screen)
	move_child(GV.shop_screen, 0)
	GV.shop_screen.get_node("Camera/UI_Layer").add_child(GV.popup_message)
	
	var result = yield(Server_Connection.connect_to_server_async(), "completed")
	if(result != OK):		
		critical_error("Verbindungsfehler Server")
	
	result = yield(Server_Connection.get_world_id_async(), "completed")
	if(result != OK):		
		critical_error("Welt ID nicht erhalten")
	
	result = yield(Server_Connection.join_world_async(), "completed")
	if(result != OK):
		critical_error("Verbindungsfehler Welt")
	var world_data = yield(Server_Connection.get_world_data_async(), "completed")
	var save_state = yield(Server_Connection.get_save_state_async(), "completed")
	if(world_data != null && save_state != null):
		receive_ware_data_update(world_data)
		receive_save_data(save_state)
	else:
		critical_error("Fehlende Spielstände und Weltdaten")

#Verarbeiten der Eingehenden Nachrichten vom Server
func process_server_message(message):
	var data = message.rsplit(":")
	match(int(data[0])):
		0: login_request_answer(data[1])
		1: receive_ware_data_update(data[1])
		2: receive_save_data(data[1])
		3: receive_action_permition(data[1])

#Verarbeite Antworten auf Login- und Registrierungsanfragen
func login_request_answer(answer):
	var data = parse_json(answer)
	if(data[1]):
		succesfull_login()
	else:
		if(data[1]):
			GV.login_screen.set_feedback_note("Login Name vergeben")
		else:
			GV.login_screen.set_feedback_note("Login Name oder Password falsch")

#Verarbeitet updates der Warendaten
func receive_ware_data_update(answer):
	var data = parse_json(answer)
	GV.ware_data = data

#Verarbeitet den eingehenden Speicherstand
func receive_save_data(answer):
	var data = parse_json(answer)
	GV.update_money(data[0])
	GV.update_workforce(data[1])
	GV.update_activ_workforce(data[6])
	GV.shop_screen.load_savestate(data[2], data[3], data[4])
	for ware in data[5]:
		GV.storage_screen.add_ware(ware[0],ware[1])

#Weiterleitung von server Antworten 
func receive_action_permition(answer):
	var action_id = parse_json(answer)
	match(int(action_id[0])):
		0: GV.shop_screen.extend_shop(action_id[1])
		1: GV.shop_screen.construct_wall(action_id[1])
		2: GV.shop_screen.construct_room(action_id[1])
		3: GV.shop_screen.construct_funiture(action_id[1])
		4: GV.shop_screen.delete_object(action_id[1])
		5: GV.market_screen.commit_buy(action_id[1])
		6: GV.market_screen.commit_sell(action_id[1])
		7: GV.shop_screen.production_window.start_production(action_id[1])
		9: GV.shop_screen.action_on_request.abort_action(action_id[1])
		10: GV.shop_screen.commit_hire()
		11: GV.shop_screen.commit_layoff()

#Zeigt eine Kritische Fehlermeldung und schließt den Clienten anschließend
func critical_error(message):
	GV.popup_message.accept_button.connect("pressed", self, "quit_game")
	GV.popup_message.show_popup(message)

#Spiel schließen
func quit_game():
	Server_Connection.close_connection()
	Server_Connection.queue_free()
	GV.login_screen.queue_free()
	GV.shop_screen.queue_free()
	GV.queue_free()
	get_tree().quit()
