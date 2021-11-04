extends Panel

var production_panel
var sell_panel
var action_panel

var P_upgrade_button
var P_ware_list
var P_ware_name
var P_ware_image
var P_ware_description
var P_ware_cost_list
var P_ware_time_needet
var P_amount_input

var s_upgrade_button
var s_ware_list
var s_ware_name
var s_ware_image
var s_ware_description
var s_amount_input

var a_upgrade_button
var a_ware_name
var a_ware_image
var a_ware_description
var a_queue_label
var a_amount_input

var ware_for_funiture

var window_mode					#0 = production_ansicht, 1 = sell_ansicht, 2 = action_ansicht
var border
var actual_funiture
var actual_amount = 1
var actual_ware
var actual_cost_list

# Called when the node enters the scene tree for the first time.
func _ready():
	
	production_panel = get_node("Production_Panel")
	sell_panel = get_node("Sell_Panel")
	action_panel = get_node("Action_Overview_Panel")
	
	P_upgrade_button = get_node("Production_Panel/Border_Margin/HBox_Split/Ware_Margin/VBox_Split/Upgrade_Button")
	P_ware_list = get_node("Production_Panel/Border_Margin/HBox_Split/Ware_Margin/VBox_Split/Ware_Scroll/Ware_VBox")
	P_ware_name = get_node("Production_Panel/Border_Margin/HBox_Split/Description_Margin/Description_VBox/Ware_Name")
	P_ware_image = get_node("Production_Panel/Border_Margin/HBox_Split/Description_Margin/Description_VBox/MarginContainer/Panel/Ware_Image")
	P_ware_description = get_node("Production_Panel/Border_Margin/HBox_Split/Description_Margin/Description_VBox/Ware_Description")
	P_ware_cost_list = get_node("Production_Panel/Border_Margin/HBox_Split/Cost_VBox/Cost_Scroll/Cost_VBox")
	P_ware_time_needet = get_node("Production_Panel/Border_Margin/HBox_Split/Cost_VBox/Time_Needet")
	P_amount_input = get_node("Production_Panel/Border_Margin/HBox_Split/Cost_VBox/Amount_HBox/Amount_Input")
	
	s_upgrade_button = get_node("Sell_Panel/Border_Margin/HBox_Split/Ware_Margin/VBox_Split/Upgrade_Button")
	s_ware_list = get_node("Sell_Panel/Border_Margin/HBox_Split/Ware_Margin/VBox_Split/Ware_Scroll/Ware_VBox")
	s_ware_name = get_node("Sell_Panel/Border_Margin/HBox_Split/Description_Margin/Description_VBox/Ware_Name")
	s_ware_image = get_node("Sell_Panel/Border_Margin/HBox_Split/Description_Margin/Description_VBox/MarginContainer/Panel/Ware_Image")
	s_ware_description = get_node("Sell_Panel/Border_Margin/HBox_Split/Description_Margin/Description_VBox/Ware_Description")
	s_amount_input = get_node("Sell_Panel/Border_Margin/HBox_Split/Sell_VBox/Amount_HBox/Amount_Input")
	
	a_upgrade_button = get_node("Action_Overview_Panel/Border_Margin/HBox_Split/Ware_Margin/VBox_Split/Upgrade_Button")
	a_ware_name = get_node("Action_Overview_Panel/Border_Margin/HBox_Split/Description_Margin/Description_VBox/Ware_Name")
	a_ware_image = get_node("Action_Overview_Panel/Border_Margin/HBox_Split/Description_Margin/Description_VBox/MarginContainer/Panel/Ware_Image")
	a_ware_description = get_node("Action_Overview_Panel/Border_Margin/HBox_Split/Description_Margin/Description_VBox/Ware_Description")
	a_queue_label = get_node("Action_Overview_Panel/Border_Margin/HBox_Split/Action_VBox/Queue_Label")
	a_amount_input = get_node("Action_Overview_Panel/Border_Margin/HBox_Split/Action_VBox/Amount_HBox/Amount_Input")
	
	P_amount_input.connect("text_changed", self, "check_input")
	get_node("Production_Panel/Border_Margin/HBox_Split/Cost_VBox/Close_Button_Margin/Close_Button").connect("pressed", self, "hide_menue")
	get_node("Production_Panel/Border_Margin/HBox_Split/Cost_VBox/Amount_HBox/Up_Button").connect("pressed", self, "up_button_press")
	get_node("Production_Panel/Border_Margin/HBox_Split/Cost_VBox/Amount_HBox/Down_Button").connect("pressed", self, "down_button_press")
	get_node("Production_Panel/Border_Margin/HBox_Split/Cost_VBox/Accept_Button").connect("pressed", self, "accept")
	
	s_amount_input.connect("text_changed", self, "check_input")
	get_node("Sell_Panel/Border_Margin/HBox_Split/Sell_VBox/Close_Button_Margin/Close_Button").connect("pressed", self, "hide_menue")
	get_node("Sell_Panel/Border_Margin/HBox_Split/Sell_VBox/Amount_HBox/Up_Button").connect("pressed", self, "up_button_press")
	get_node("Sell_Panel/Border_Margin/HBox_Split/Sell_VBox/Amount_HBox/Down_Button").connect("pressed", self, "down_button_press")
	get_node("Sell_Panel/Border_Margin/HBox_Split/Sell_VBox/Accept_Button").connect("pressed", self, "accept")
	
	a_amount_input.connect("text_changed", self, "check_input")
	get_node("Action_Overview_Panel/Border_Margin/HBox_Split/Action_VBox/Close_Button_Margin/Close_Button").connect("pressed", self, "hide_menue")
	get_node("Action_Overview_Panel/Border_Margin/HBox_Split/Action_VBox/Amount_HBox/Up_Button").connect("pressed", self, "up_button_press")
	get_node("Action_Overview_Panel/Border_Margin/HBox_Split/Action_VBox/Amount_HBox/Down_Button").connect("pressed", self, "down_button_press")
	get_node("Action_Overview_Panel/Border_Margin/HBox_Split/Action_VBox/Accept_Button").connect("pressed", self, "accept")

#Universelle Funktionen
func show_menue():
	var viewport_size = get_viewport().get_visible_rect().size
	var x = (viewport_size.x - get_rect().size.x) / 2
	var y = (viewport_size.y - get_rect().size.y) / 2
	
	set_position(Vector2(x,y))
	
	GV.shop_screen.action_window_visible = true
	self.visible = true

func hide_menue():
	
	GV.shop_screen.action_window_visible = false
	self.visible = false;

func up_button_press():
	var input
	match(window_mode):
		0: input = P_amount_input
		1: input = s_amount_input
		2: input = a_amount_input
	
	actual_amount += 1
	input.set_text(String(actual_amount))
	update_amount()

func down_button_press():
	var input
	match(window_mode):
		0: input = P_amount_input
		1: input = s_amount_input
		2: input = a_amount_input
	
	if(actual_amount > 0):
		actual_amount -= 1
		input.set_text(String(actual_amount))
		update_amount()

func check_input(text):
	
	var input
	match(window_mode):
		0: input = P_amount_input
		1: input = s_amount_input
		2: input = a_amount_input
	
	if(text.is_valid_integer()):
		actual_amount = int(text)
		if(actual_amount > border):
			actual_amount = 100
			input.set_text(String(actual_amount))
		elif(actual_amount < 0):
			actual_amount = 1
			input.set_text(String(actual_amount))
		update_amount()
	else:
		input.set_text(String(actual_amount))

func accept():
	if(window_mode == 0):
		if(GV.actual_workforce[0] > GV.actual_workforce[1]):
			Server_Connection.send_action_async(8, JSON.print([actual_ware[0], actual_amount, actual_funiture.own_tile.coordinates]))
		else:
			GV.popup_message.show_popup("Kein Arbeiter frei")
	elif(window_mode == 1):
		Server_Connection.send_action_async(10, JSON.print([actual_ware[0], actual_amount, actual_funiture.own_tile.coordinates]))
	elif(window_mode == 2):
		Server_Connection.send_action_async(11, JSON.print([actual_amount, actual_funiture.own_tile.coordinates]))

func set_picture(id):
	var image
	match(window_mode):
		0: image = P_ware_image
		1: image = s_ware_image
		2: image = a_ware_image
	
	match(id):
		0: image.set_texture(GV.grafic_library.ware["Copper"])
		1: image.set_texture(GV.grafic_library.ware["Iron"])
		2: image.set_texture(GV.grafic_library.ware["Chainlink"])
		3: image.set_texture(GV.grafic_library.ware["Ironhelmet"])
		4: image.set_texture(GV.grafic_library.ware["Chainmail"])

func time_to_string(time):
	time = int(time)
	var seconds = time % 60
	var minutes = ((time % 3600) - seconds) / 60
	var hours = (time - (time % 3600)) / 3600
	if(seconds < 10):
		seconds = "0" + String(seconds)
	if(minutes < 10):
		minutes = "0" + String(minutes)
	if(hours < 10):
		hours = "0" + String(hours)
	return (String(hours) + ":" + String(minutes) + ":" + String(seconds))

func update_amount():
	if(window_mode == 0):
		P_ware_time_needet.set_text("Produktionsdauer: " + time_to_string(((1 - actual_funiture.own_tile.room.get_bonus()) * actual_ware[5]) * actual_amount))
		var i = 0
		var on_stock
		for child in P_ware_cost_list.get_children():
			on_stock = GV.storage_screen.get_actual_amount(actual_cost_list[i][0])
			child.set_text(String(GV.ware_data[actual_cost_list[i][0]][2]) + ": " + String(actual_cost_list[i][1] * actual_amount) + "/" + String(on_stock))
			i += 1
	elif(window_mode == 1):
		pass

#Produktions Funktionen
func set_production_funiture(funiture):
	window_mode = 0
	border = 100
	
	sell_panel.visible = false
	action_panel.visible = false
	production_panel.visible = true
	
	actual_funiture = funiture
	ware_for_funiture = GV.FUNITURE_DATA[funiture.id][5]
	
	for button in P_ware_list.get_children():
		button.queue_free()
	
	var new_button
	for ware in ware_for_funiture:
		new_button = Game_Button.new()
		new_button.set_text(GV.ware_data[ware][2])
		new_button.connect("pressed", self, "chose_ware", [new_button])
		P_ware_list.add_child(new_button)
	chose_ware(P_ware_list.get_child(0))

func chose_ware(source):
	actual_amount = 1
	P_amount_input.set_text(String(actual_amount))
	actual_ware = GV.ware_data[ware_for_funiture[source.get_index()]]
	P_ware_name.set_text(actual_ware[2])
	P_ware_description.set_text(actual_ware[3])
	set_picture(int(actual_ware[0]))
	actual_cost_list = actual_ware[4]
	set_cost_list(actual_ware[4])
	P_ware_time_needet.set_text("Produktionsdauer: " + time_to_string(((1 - actual_funiture.own_tile.room.get_bonus()) * actual_ware[5]) * actual_amount))

func set_cost_list(cost_list):
	for child in P_ware_cost_list.get_children():
		child.queue_free()
	var new_line
	var on_stock
	for ware in cost_list:
		on_stock = GV.storage_screen.get_actual_amount(ware[0])
		new_line = Label.new()
		new_line.set_text(String(GV.ware_data[ware[0]][2]) + ": " + String(ware[1] * actual_amount) + "/" + String(on_stock))
		P_ware_cost_list.add_child(new_line)

func start_production(ok):
	if(ok):
		GV.update_activ_workforce(1)
		actual_funiture.start_action(3, (1 - actual_funiture.own_tile.room.get_bonus()) * actual_ware[5], actual_ware[0], actual_amount)
		hide_menue()
	else:
		GV.main.critical_error("Fehler bei Serverabgleich")
	GV.await_server_answer = false

#Verkaufs Funktionen
func set_sell_funiture(funiture):
	window_mode = 1 
	
	action_panel.visible = false
	production_panel.visible = false
	sell_panel.visible = true
	
	actual_funiture = funiture
	ware_for_funiture = get_ware_for_sale()
	
	for button in s_ware_list.get_children():
		button.queue_free()
	
	var new_button
	for ware in ware_for_funiture:
		new_button = Game_Button.new()
		new_button.set_text(ware[2])
		new_button.connect("pressed", self, "chose_sell_ware", [new_button])
		s_ware_list.add_child(new_button)
	if(ware_for_funiture.size() != 0):
		chose_sell_ware(s_ware_list.get_child(0))
	else:
		var label = Label.new()
		label.set_text("Keine Waren")
		get_node("Sell_Panel/Border_Margin/HBox_Split/Sell_VBox/Accept_Button").set_disabled(true)
		get_node("Sell_Panel/Border_Margin/HBox_Split/Sell_VBox/Amount_HBox/Up_Button").set_disabled(true)
		get_node("Sell_Panel/Border_Margin/HBox_Split/Sell_VBox/Amount_HBox/Down_Button").set_disabled(true)
		s_ware_list.add_child(label)

	#Waren für den Privat verkauf auflisten
func get_ware_for_sale():
	var ware_list = []
	var ware_data = GV.ware_data
	for ware in ware_data:
		if(ware[1] == 2):
			ware_list.append(ware)
	return ware_list

func chose_sell_ware(source):
	actual_amount = 1
	s_amount_input.set_text(String(actual_amount))
	actual_ware = ware_for_funiture[source.get_index()]
	border = GV.storage_screen.get_actual_amount(actual_ware[0])
	s_ware_name.set_text(actual_ware[2])
	s_ware_description.set_text(actual_ware[3])
	set_picture(int(actual_ware[0]))

func start_sell(ok):
	if(ok):
		actual_funiture.start_action(4, 0, actual_ware[0], actual_amount)
		hide_menue()
	else:
		GV.main.critical_error("Fehler bei Serverabgleich")
	GV.await_server_answer = false

#Actionen abändern
func edit_action(funiture):
	window_mode = 2
	border = funiture.aditional_data
	production_panel.visible = false
	sell_panel.visible = false
	action_panel.visible = true
	
	actual_funiture = funiture
	a_queue_label.set_text(String(border))
	a_amount_input.set_text(String(actual_amount))
	actual_ware = GV.ware_data[funiture.actual_action_outcome]
	a_ware_name.set_text(actual_ware[2])
	a_ware_description.set_text(actual_ware[3])
	set_picture(int(actual_ware[0]))

func update_queue(update):
	border += update
	a_queue_label.set_text(String(border))
	actual_amount = border
	a_amount_input.set_text(String(actual_amount))
	if(border == 0):
		hide_menue()

func commit_update(ok):
	if(ok):
		if(actual_amount == 0):
			actual_funiture.abort_action()
			hide_menue()
		else:
			actual_funiture.update_action(actual_amount)
	else:
		GV.main.critical_error("Fehler bei Serverabgleich")
	GV.await_server_answer = false
