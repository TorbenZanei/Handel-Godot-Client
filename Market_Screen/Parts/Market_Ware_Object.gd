extends Panel

#Einzelteile der Scene
var name_label
var image
var description
var price_label
var pack_price_label
var storage_label
var amount_edit
var amount_up_button
var amount_down_button
var accept_button

#Kauf- oder Verkaufsansicht
var actual_mode

#Momentan Angezeigte Ware und Ausgewählte Menge
var actual_ware
var actual_amount = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	name_label = get_node("Main_Margin/HBox_Split/Margin_Left_Part/VBox_Left_part/Name")
	image = get_node("Main_Margin/HBox_Split/Margin_Left_Part/VBox_Left_part/Margin_Picture/Panel/Picture")
	description = get_node("Main_Margin/HBox_Split/Margin_Description/Description")
	price_label = get_node("Main_Margin/HBox_Split/VBox_Input/Label_Price")
	storage_label = get_node("Main_Margin/HBox_Split/VBox_Input/Label_Storage")
	amount_edit = get_node("Main_Margin/HBox_Split/VBox_Input/HBox_Amount/LineEdit_Amount")
	amount_up_button = get_node("Main_Margin/HBox_Split/VBox_Input/HBox_Amount/Amount_Up_Button")
	amount_down_button = get_node("Main_Margin/HBox_Split/VBox_Input/HBox_Amount/Amount_Down_Button")
	pack_price_label = get_node("Main_Margin/HBox_Split/VBox_Input/HBox_Final/Label_pack_value")
	accept_button = get_node("Main_Margin/HBox_Split/VBox_Input/HBox_Final/Accept_Button")
	accept_button.sound_effect_click_id = GV.sound_player.COIN_SOUND
	
	amount_edit.connect("text_changed", self, "check_if_input_is_number")
	amount_up_button.connect("pressed", self, "up_button_press")
	amount_down_button.connect("pressed", self, "down_button_press")
	accept_button.connect("pressed", self, "accept")

func set_ware(ware, mode):
	actual_mode = mode
	actual_ware = ware
	name_label.set_text(ware[2])
	description.set_text(ware[3])
	amount_edit.set_text(String(actual_amount))
	set_picture(int(actual_ware[0]))
	if(actual_mode == 1):
		price_label.set_text("Preis: " + String(ware[6] * 0.7))
		storage_label.set_text("Auf Lager: " + String(GV.storage_screen.get_actual_amount(actual_ware[0])))
		pack_price_label.set_text("0")
		accept_button.set_text("Verkaufen")
	elif(actual_mode == 0):
		price_label.set_text("Preis: " + String(ware[6]))
		storage_label.set_text("Freier Lagerplatz: " + String(GV.storage_screen.get_free_storage(actual_ware[1])))
		pack_price_label.set_text("0")
		accept_button.set_text("Kaufen")
	update()

func set_picture(id):
	match(id):
		0: image.set_texture(GV.grafic_library.ware["Copper"])
		1: image.set_texture(GV.grafic_library.ware["Iron"])
		2: image.set_texture(GV.grafic_library.ware["Chainlink"])
		3: image.set_texture(GV.grafic_library.ware["Ironhelmet"])
		4: image.set_texture(GV.grafic_library.ware["Chainmail"])

func set_to_buy():
	actual_mode = 0
	price_label.set_text("Preis: " + String(actual_ware[6]))
	storage_label.set_text("Freier Lagerplatz: " + String(GV.storage_screen.get_free_storage(actual_ware[1])))
	pack_price_label.set_text(String(actual_ware[6] * actual_amount))
	accept_button.set_text("Kaufen")
	self.visible = true

func set_to_sell():
	actual_mode = 1
	price_label.set_text("Preis: " + String(actual_ware[6] * 0.7))
	storage_label.set_text("Auf Lager: " + String(GV.storage_screen.get_actual_amount(actual_ware[0])))
	pack_price_label.set_text(String(actual_ware[6] * actual_amount * 0.7))
	accept_button.set_text("Verkaufen")
	if(GV.storage_screen.get_actual_amount(actual_ware[0]) == 0):
		self.visible = false
	else:
		self.visible = true

func update():
	if(actual_mode == 1):
		storage_label.set_text("Auf Lager: " + String(GV.storage_screen.get_actual_amount(actual_ware[0])))
		pack_price_label.set_text("0")
		if(GV.storage_screen.get_actual_amount(actual_ware[0]) == 0):
			self.visible = false
		else:
			self.visible = true
	elif(actual_mode == 0):
		storage_label.set_text("Freier Lagerplatz: " + String(GV.storage_screen.get_free_storage(actual_ware[1])))
		pack_price_label.set_text("0")

func still_on_stock():
	if(GV.storage_screen.get_actual_amount(actual_ware[0]) > 0):
		return true
	else:
		return false

#Prüfen ob der im Input eingegebene Wert eine gültige Zahl ist
func check_if_input_is_number(text):
	if(text.is_valid_integer()):
		actual_amount = int(text)
		if(actual_mode == 0):
			var storage_space = GV.storage_screen.get_free_storage(actual_ware[1])
			if(actual_amount > storage_space):
				actual_amount = storage_space
				amount_edit.set_text(String(actual_amount))
			elif(actual_amount < 0):
				actual_amount = 0
				amount_edit.set_text(String(actual_amount))
			pack_price_label.set_text(String(actual_ware[6] * actual_amount))
		elif(actual_mode == 1):
			var in_storage = GV.storage_screen.get_actual_amount(actual_ware[0])
			if(actual_amount > in_storage):
				actual_amount = in_storage
				amount_edit.set_text(String(actual_amount))
			elif(actual_amount < 0):
				actual_amount = 0
				amount_edit.set_text(String(actual_amount))	
			pack_price_label.set_text(String(actual_ware[6] * actual_amount * 0.7))
	else:
		amount_edit.set_text(String(actual_amount))

#Button Actions
func up_button_press():
	if(actual_mode == 1):
		var in_storage = GV.storage_screen.get_actual_amount(actual_ware[0])
		if(actual_amount < in_storage):
			actual_amount += 1
			amount_edit.set_text(String(actual_amount))
		pack_price_label.set_text(String(actual_ware[6] * actual_amount * 0.7))
	elif(actual_mode == 0):
		var storage_space = GV.storage_screen.get_free_storage(actual_ware[1])
		if(actual_amount < storage_space):
			actual_amount += 1
			amount_edit.set_text(String(actual_amount))
		pack_price_label.set_text(String(actual_ware[6] * actual_amount))

func down_button_press():
	if(actual_amount > 0):
		actual_amount -= 1
		amount_edit.set_text(String(actual_amount))
	if(actual_mode == 1):
		pack_price_label.set_text(String(actual_ware[6] * actual_amount * 0.7))
	elif(actual_mode == 0):
		pack_price_label.set_text(String(actual_ware[6] * actual_amount))

func accept():
	GV.market_screen.buy_sell_ware(self)
