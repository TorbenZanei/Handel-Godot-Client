extends Node

var own_tile = null

var id = null
var actual_action = 0							#1: Bauen 2: Abreißen 3: Produzieren 4: Verkaufen 
												#10:Pausiert kein Platz 11:Pausiert keine Ressourcen
var time_left = 0
var actual_action_outcome = 0
var aditional_data = 0							#Bei Wand: 0 no wall, 1 Wand, 2 Ausenwand, 3 Ausenwand straßenseite
												#Bei Einrichtung die anzahl der wiederholungen

var timer_visible = false
var timer_on_hold = false						#Flag dass der Timer pausiert wurde
var run_out_of_ressources = false				#Flag wenn noch wiederholungen in der produktion ausstehen aber keine ressourcen vorhanden sind
var reason = ""									#Angezeigte Begründung warum er angehalten wurde

func _init(tile, funiture_id, action, time, outcome, extra, status_flag):
	own_tile = tile
	id = funiture_id
	actual_action = action
	if(action == 4):
		time_left = 0
	else:
		time_left = time
	actual_action_outcome = outcome
	aditional_data = extra
	
	if(status_flag == 1):
		timer_visible = true
		timer_on_hold = true
		reason = "Lager voll"
	elif(status_flag == 2):
		if(actual_action == 3):
			timer_visible = true
			run_out_of_ressources = true
			timer_on_hold = true
			reason = "kein Material"
		elif(actual_action == 4):
			run_out_of_ressources = true
			timer_on_hold = true
			reason = "keine Ware"
		
	if(time_left > 0 ):
		timer_visible = true
		own_tile.set_timer_label(time_left, timer_on_hold, timer_visible)

func _ready():
	if(time_left == 0):
		finish_action()

func start_action(action, time, outcome, extra = null):
	actual_action = action
	time_left = time
	actual_action_outcome = outcome
	if( extra != null):
		aditional_data = extra
	if(actual_action == 3):
		timer_visible = true
		var actual_ware = GV.ware_data[actual_action_outcome]
		if(GV.storage_screen.check_for_ressources(actual_ware[4])):
			for ware in actual_ware[4]:
				GV.storage_screen.remove_ware(ware)
		else:
			time_left = 0
			run_out_of_ressources = true
			timer_on_hold = true
			reason = "kein Material"
	elif(actual_action == 4):
		own_tile.set_funiture_grafics()
	
	own_tile.set_timer_label(time_left, timer_on_hold, timer_visible)

func timer_tic():
	if(actual_action != 0 && actual_action != 4):
		if(time_left <= 0):
			finish_action()
			own_tile.set_timer_label(time_left, timer_on_hold, timer_visible)
		else:
			time_left -= 1
			own_tile.set_timer_label(time_left, timer_on_hold, timer_visible)
	elif(actual_action != 0 && actual_action == 4):
		own_tile.set_timer_label(time_left, timer_on_hold, timer_visible)

func finish_action():
	if(actual_action == 1):
		if(own_tile.state == 2):
			id = actual_action_outcome
			actual_action = 0
			actual_action_outcome = 0
		elif(own_tile.state == 3):
			id = actual_action_outcome
			actual_action = 0
			actual_action_outcome = 0
			if(GV.FUNITURE_DATA[id][4] == 0):
				GV.storage_screen.add_storage_funiture(self)
			elif(GV.FUNITURE_DATA[id][4] == 2):
				own_tile.room.add_enhancing_funiture(self)
		own_tile.set_funiture_grafics()
		timer_visible = false
	elif(actual_action == 2):
		pass
	elif(actual_action == 3):
		if(run_out_of_ressources):
			var actual_ware = GV.ware_data[actual_action_outcome]
			if(GV.storage_screen.check_for_ressources(actual_ware[4])):
				run_out_of_ressources = false
				timer_on_hold = false
				for ware in actual_ware[4]:
					GV.storage_screen.remove_ware(ware)
				time_left = (1 - own_tile.room.get_bonus()) * actual_ware[5]
		else:
			if(GV.storage_screen.check_for_space(actual_action_outcome, 1)):
				reason = ""
				GV.storage_screen.add_ware(actual_action_outcome, 1)
				aditional_data -= 1
				if(GV.shop_screen.action_window_visible):
					GV.shop_screen.action_window.update_queue(-1)
				if(aditional_data == 0):
					timer_on_hold = false
					time_left = 0
					actual_action = 0
					actual_action_outcome = 0
					timer_visible = false
					GV.update_activ_workforce(-1)
				else:
					var actual_ware = GV.ware_data[actual_action_outcome]
					if(GV.storage_screen.check_for_ressources(actual_ware[4])):
						timer_on_hold = false
						for ware in actual_ware[4]:
							GV.storage_screen.remove_ware(ware)
						time_left = (1 - own_tile.room.get_bonus()) * actual_ware[5]
					else:
						run_out_of_ressources = true
						timer_on_hold = true
						reason = "kein Material"
			else:
				timer_on_hold = true
				reason = "Lager voll"
	elif(actual_action == 4):
		pass

func chose_tile():
	if(actual_action == 0):
		if(GV.FUNITURE_DATA[id][4] == 1):
			GV.shop_screen.action_window.set_production_funiture(self)
			GV.shop_screen.action_window.show_menue()
		elif(GV.FUNITURE_DATA[id][4] == 3):
			GV.shop_screen.action_window.set_sell_funiture(self)
			GV.shop_screen.action_window.show_menue()
	elif(actual_action == 1):
		GV.conformation_request.request_answer(self,"Bau Abbrechen ?")
	elif(actual_action == 3):
		GV.shop_screen.action_window.edit_action(self)
		GV.shop_screen.action_window.show_menue()
	elif(actual_action == 4):
		GV.shop_screen.action_window.edit_action(self)
		GV.shop_screen.action_window.show_menue()

func accept_action(accepted):
	if(accepted):
		GV.shop_screen.action_on_request = self
		Server_Connection.send_action_async(9, JSON.print([own_tile.coordinates]))

func abort_action():
	if(actual_action == 1):
		own_tile.abort_construction()
	elif(actual_action == 3):
		actual_action = 0
		time_left = 0
		timer_visible = false
		timer_on_hold = false
		actual_action_outcome = 0
		aditional_data = 0
		own_tile.set_timer_label(time_left, timer_on_hold, timer_visible)
		GV.update_activ_workforce(-1)
	elif(actual_action == 4):
		actual_action = 0
		aditional_data = 0
		own_tile.set_funiture_grafics()
		
	GV.await_server_answer = false

func update_action(update):
	GV.shop_screen.action_window.update_queue(-aditional_data + update)
	aditional_data = update
	

func ware_sold():
	if(GV.storage_screen.get_actual_amount(actual_action_outcome) >= 1):
		aditional_data -= 1
		
		if(run_out_of_ressources):
			run_out_of_ressources = false
			timer_on_hold = false
			reason = ""
		
		var ware_data = GV.ware_data[actual_action_outcome]
		GV.update_money(-(ware_data[6] * 2))
		GV.market_screen.remove_ware([actual_action_outcome, 1])
		
		show_effect(1,1)
		
		if(aditional_data == 0):
			actual_action = 0
			actual_action_outcome = 0
		
		
	else:
		run_out_of_ressources = true
		timer_on_hold = true
		reason = "keine Ware"

func play_soundclip():
	match(int(id)):
		0: GV.sound_player.play_effect(GV.sound_player.BUTTON_CLICK)
		1: GV.sound_player.play_effect(GV.sound_player.BUTTON_CLICK)
		2: GV.sound_player.play_effect_os(GV.sound_player.SMITHY_WORKPLACE)
		3: GV.sound_player.play_effect(GV.sound_player.BUTTON_CLICK)

func show_effect(effect_id, time):
	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = time
	own_tile.set_effect(true)
	timer.start()
	yield(timer, "timeout")
	own_tile.set_effect(false)

func delete_self():
	self.queue_free()
